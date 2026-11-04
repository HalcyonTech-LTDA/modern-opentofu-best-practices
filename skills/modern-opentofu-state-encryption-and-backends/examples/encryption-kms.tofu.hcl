# Production AWS KMS OpenTofu Native State and Plan Encryption Blueprint
# Requires OpenTofu >= 1.7.0

terraform {
  encryption {
    # Key provider utilizing AWS Key Management Service (KMS)
    key_provider "aws_kms" "production_kms" {
      kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/example-kms-key-uuid"
      region     = "us-east-1"
      key_spec   = "AES_256"
    }

    # Authenticated AEAD Encryption Method
    method "aes_gcm" "kms_aes_gcm" {
      keys = key_provider.aws_kms.production_kms
    }

    # Enforce on state storage
    state {
      method   = method.aes_gcm.kms_aes_gcm
      enforced = true
    }

    # Enforce on generated plan artifacts
    plan {
      method   = method.aes_gcm.kms_aes_gcm
      enforced = true
    }
  }
}
