---
name: modern-opentofu-state-encryption-and-backends
description: >-
  Use this skill when configuring OpenTofu state storage, state and plan encryption,
  remote backend architectures, state locking, and blast-radius segmentation:
  native encryption blocks (OpenTofu 1.7+), AES-GCM AEAD, key providers (pbkdf2, aws_kms, gcp_kms,
  azure_keyvault, openbao), state and plan target enforcement, S3/DynamoDB backends, Azure Blob leasing,
  Google Cloud Storage backends, and multi-tier state isolation.
---

# Modern OpenTofu State Encryption & Backend Architecture

This skill provides comprehensive architectural patterns and configuration specifications for securing OpenTofu state files and plans at rest and in transit using **OpenTofu Native State Encryption** (introduced in OpenTofu 1.7), alongside resilient remote backends and state locking.

---

## Core Engineering Principles

1. **OpenTofu Native State Encryption (OpenTofu 1.7+)**:
   - OpenTofu solves the multi-decade challenge of plaintext secrets in state files by introducing native state encryption directly into the engine.
   - Configure declarative `encryption { ... }` blocks to encrypt both `state` and speculative `plan` files before they touch local disk or remote object storage.
   - Employ authenticated encryption: AES-GCM (`aes_gcm`) with 256-bit keys or AES-CBC with HMAC.

2. **Enterprise Key Providers**:
   - **`pbkdf2`**: Derives strong keys from passphrases supplied via environment variables (`TF_ENCRYPTION_PASSPHRASE`). Ideal for local development, CI runners, or air-gapped environments.
   - **`aws_kms`**: Envelope encryption using AWS Key Management Service Customer Master Keys (CMKs).
   - **`gcp_kms`**: Google Cloud Cloud KMS integration.
   - **`azure_keyvault`**: Azure Key Vault Cryptographic Key integration.
   - **`openbao` / HashiCorp Vault**: Native Transit Secrets Engine integration.

3. **Dual Target Encryption (`state` and `plan`)**:
   - Encrypting state alone is insufficient. Speculative plan files (`tfplan`) often contain unencrypted plaintext sensitive values.
   - Always declare encryption targets for both `state` and `plan`, setting `enforced = true`.

4. **Key Rotation & Migration Fallback**:
   - Define fallback key providers to allow non-disruptive key rotation. OpenTofu will attempt decryption using fallback keys and re-encrypt the state using the primary active key on subsequent writes.

5. **Blast-Radius State Segmentation**:
   - Never manage an entire enterprise or multi-tier environment in a single state file.
   - Separate state by lifecycle boundary:
     - Foundation (`networking`, `dns`, `shared-kms`)
     - Data Persistence (`rds`, `mongodb`, `s3-data`)
     - Compute Platform (`eks`, `ecs`, `kubernetes`)
     - Application Workloads (`microservices`, `helm-releases`)
   - Avoid `tofu_remote_state` anti-patterns that expose full state contents; decouple components using cloud parameter stores (AWS SSM, Azure Key Vault, HashiCorp Vault).

---

## Directory Resources & References

- **Detailed Guides**:
  - [Native State & Plan Encryption Guide](./references/native_state_encryption.md)
  - [Remote Backends & State Locking](./references/remote_backends_and_locking.md)
  - [State Isolation & Blast-Radius Management](./references/state_isolation_and_blast_radius.md)
- **Reference Implementations**:
  - [AWS KMS Native Encryption Template](./examples/encryption-kms.tofu.hcl)
  - [Passphrase PBKDF2 Encryption Template](./examples/encryption-passphrase.tofu.hcl)
  - [S3 + DynamoDB Backend Architecture](./examples/backend-s3-dynamodb.tf)
  - [Azure Blob Storage with Lease Lock](./examples/backend-azure-blob.tf)
