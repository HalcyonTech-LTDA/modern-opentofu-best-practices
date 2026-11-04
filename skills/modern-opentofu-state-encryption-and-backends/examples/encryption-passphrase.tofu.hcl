# Passphrase / PBKDF2 OpenTofu Native State and Plan Encryption Blueprint
# Useful for local testing, CI runners, or air-gapped deployments.
# Passphrase can be supplied via TF_ENCRYPTION_PASSPHRASE environment variable.

terraform {
  encryption {
    key_provider "pbkdf2" "ci_passphrase" {
      passphrase  = var.state_passphrase
      key_length  = 32
      iterations  = 600000
      salt_length = 32
      hash        = "sha512"
    }

    method "aes_gcm" "passphrase_aes_gcm" {
      keys = key_provider.pbkdf2.ci_passphrase
    }

    state {
      method   = method.aes_gcm.passphrase_aes_gcm
      enforced = true
    }

    plan {
      method   = method.aes_gcm.passphrase_aes_gcm
      enforced = true
    }
  }
}

variable "state_passphrase" {
  type        = string
  description = "Cryptographic passphrase used to derive OpenTofu state encryption key."
  sensitive   = true
  nullable    = false
}
