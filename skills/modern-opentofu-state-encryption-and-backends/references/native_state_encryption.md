# OpenTofu Native State & Plan Encryption (OpenTofu 1.7+)

State files contain complete cryptographic representations of infrastructure, including database passwords, private TLS certificates, IAM credentials, and API tokens. OpenTofu 1.7 introduced native, client-side cryptographic state encryption.

---

## 1. Architectural Model

OpenTofu native encryption operates client-side before state or plan files are written to disk or sent to a remote backend (such as S3, Azure Blob, GCS, or Scalr). 

The architecture consists of three components:
1. **Key Provider (`key_provider`)**: Retrieves or derives encryption keys (e.g. AWS KMS, GCP KMS, Azure Key Vault, OpenBao/Vault, PBKDF2).
2. **Encryption Method (`method`)**: Defines the cryptographic cipher (e.g. `aes_gcm`).
3. **Encryption Target (`state` / `plan`)**: Binds methods to targets with enforcement rules.

---

## 2. Configuration Blueprint: AWS KMS

Create an encryption configuration file (e.g., `encryption.tofu.hcl` or embedded in `terraform` block):

```hcl
terraform {
  encryption {
    # 1. Define Key Provider using AWS KMS
    key_provider "aws_kms" "primary" {
      kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/b63574d6-0a12-4e67-8e43-98234ab12cd3"
      region     = "us-east-1"
      key_spec   = "AES_256"
    }

    # 2. Define Authenticated Encryption Method
    method "aes_gcm" "app_encryption" {
      keys = key_provider.aws_kms.primary
    }

    # 3. Enforce Encryption on State Files
    state {
      method   = method.aes_gcm.app_encryption
      enforced = true
    }

    # 4. Enforce Encryption on Plan Files
    plan {
      method   = method.aes_gcm.app_encryption
      enforced = true
    }
  }
}
```

---

## 3. Configuration Blueprint: PBKDF2 (Passphrase-Based)

Ideal for CI/CD pipelines and local staging environments where KMS endpoints are restricted:

```hcl
terraform {
  encryption {
    key_provider "pbkdf2" "passphrase_provider" {
      passphrase = var.encryption_passphrase # Or supplied via TF_ENCRYPTION_PASSPHRASE env var
      key_length = 32 # 256-bit AES
      iterations = 600000 # High work-factor resisting brute-force attacks
      salt_length = 32
    }

    method "aes_gcm" "passphrase_method" {
      keys = key_provider.pbkdf2.passphrase_provider
    }

    state {
      method   = method.aes_gcm.passphrase_method
      enforced = true
    }

    plan {
      method   = method.aes_gcm.passphrase_method
      enforced = true
    }
  }
}
```

---

## 4. Key Rotation & Seamless Migration

When rotating keys without causing downtime or decrypting into plaintext:

```hcl
terraform {
  encryption {
    # Active new KMS key
    key_provider "aws_kms" "new_key" {
      kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/new-key-guid"
      region     = "us-east-1"
    }

    # Deprecated previous key for reading existing state
    key_provider "aws_kms" "old_key" {
      kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/old-key-guid"
      region     = "us-east-1"
    }

    method "aes_gcm" "rotation_method" {
      keys = key_provider.aws_kms.new_key
      fallback {
        keys = key_provider.aws_kms.old_key
      }
    }

    state {
      method   = method.aes_gcm.rotation_method
      enforced = true
    }
  }
}
```

On the next `tofu apply`, OpenTofu decrypts using the fallback key, re-encrypts using `new_key`, and saves the updated ciphertext.
