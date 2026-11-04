# Modern OpenTofu Best Practices Plugin

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![OpenTofu](https://img.shields.io/badge/OpenTofu-1.8+-orange.svg)](https://opentofu.org/)
[![Antigravity](https://img.shields.io/badge/Antigravity-Plugin-purple.svg)](https://antigravity.google/)
[![GitHub](https://img.shields.io/badge/Organization-HalcyonTech--LTDA-black.svg)](https://github.com/HalcyonTech-LTDA)

An enterprise-grade Antigravity plugin establishing automated engineering guardrails, architectural patterns, native cryptographic state encryption, shift-left testing frameworks, and GitOps CI/CD standards for modern cloud infrastructure using **OpenTofu 1.8+**.

---

## Installation

### Antigravity

Install directly in Antigravity via the CLI:

```bash
agy plugin install https://github.com/HalcyonTech-LTDA/modern-opentofu-best-practices
```

Verify that the plugin is installed and ready:

```bash
agy plugin list
```

### Claude Code

Add the Halcyon Tech marketplace once, then install the plugin:

```text
/plugin marketplace add HalcyonTech-LTDA/halcyon-plugins
/plugin install modern-opentofu-best-practices@halcyon-plugins
```

Skills are namespaced by plugin in Claude Code (`/modern-opentofu-best-practices:<skill-name>`). The guardrails in `rules/` load through the skills in `claude/skills/`.

---

## Overview

Modern cloud engineering demands infrastructure as code that is deterministic, modular, drift-resistant, tested like real software, and free of plaintext secret exposure. Without strict engineering discipline, multi-cloud OpenTofu/Terraform codebases frequently suffer from severe failure modes:

- **Plaintext Secret State Leaks**: Storing database passwords, TLS certificates, and API tokens in unencrypted state files and pipeline plan artifacts.
- **The Monolithic State Anti-Pattern**: Managing entire cloud estates across networking, databases, and apps in a single state file, causing 30-minute plans, lock deadlocks, and catastrophic blast radius.
- **Untested Infrastructure Code**: Treating IaC as "untestable text" rather than software, deferring syntax and policy failures to runtime cloud deployment crashes.
- **Long-Lived CI/CD Credentials**: Baking static cloud provider access keys into repository secrets instead of using short-lived OpenID Connect (OIDC) federation.
- **Destructive Imperative State Surgery**: Running risky, unreviewed manual CLI commands (`tofu state rm`, `tofu state mv`) on engineer laptops during refactoring.
- **Untracked FinOps Spend & Tagging Chaos**: Deploying cloud assets without standardized provider default tags, preventing cost allocation and accountability.

This plugin establishes production-grade engineering standards for OpenTofu across **six comprehensive pillars**:

```text
                                  ┌────────────────────────────────────────┐
                                  │   Modern OpenTofu Engineering System   │
                                  └──────────────────┬─────────────────────┘
                                                     │
         ┌───────────────────┬───────────────────────┼───────────────────────┬───────────────────┐
         ▼                   ▼                       ▼                       ▼                   ▼
┌─────────────────┐ ┌─────────────────┐    ┌──────────────────┐    ┌──────────────────┐ ┌─────────────────┐
│ Modular Design  │ │Native Encryption│    │Shift-Left Testing│    │Quality Gates & SA│ │GitOps & OIDC CI │
│ & Early Vars    │ │& Remote Backends│    │ (Native tofu test│    │(TFLint & Trivy)  │ │ (Deterministic  │
│  (1.8+ Engine)  │ │  (AES-GCM/KMS)  │    │  Mock Providers) │    │  Default Tags    │ │   Plan/Apply)   │
└─────────────────┘ └─────────────────┘    └──────────────────┘    └──────────────────┘ └─────────────────┘
                                                     │
                                                     ▼
                                          ┌──────────────────────┐
                                          │Lifecycle & Refactor  │
                                          │(moved, removed 1.7+, │
                                          │   prevent_destroy)   │
                                          └──────────────────────┘
```

1. **Modular Architecture & Contracts (`modern-opentofu-modular-architecture`)**: Standard file layout (`versions.tf`, `providers.tf`, `variables.tf`, `outputs.tf`), OpenTofu Registry pinning, strict typing with object schemas, custom validation blocks with descriptive errors, early variable evaluation (OpenTofu 1.8+ in backends and providers), dynamic provider iteration (`for_each`), and living documentation via `terraform-docs`.
2. **State Encryption & Remote Backends (`modern-opentofu-state-encryption-and-backends`)**: Native OpenTofu client-side encryption (`encryption` blocks with AES-GCM and AWS KMS / Azure Key Vault / GCP KMS / OpenBao / PBKDF2), state and plan target enforcement, remote backend state locking (S3 + DynamoDB, Azure Blob Lease, GCS), blast-radius segmentation, and zero secret leakage.
3. **Shift-Left Testing & Mocking Framework (`modern-opentofu-testing-and-mocking`)**: Native `tofu test` framework (`tests/*.tftest.hcl`), OpenTofu 1.8+ credential-free unit testing with `mock_provider` and resource overrides, speculative plan-based assertions (`command = plan`), ephemeral integration suites (`command = apply`), and negative testing with `expect_failures`.
4. **Security Hardening & Quality Gates (`modern-opentofu-security-and-quality-gates`)**: Pre-flight analysis (`tofu fmt -check`, `tofu validate`), custom `.tflint.hcl` rulesets, Trivy/Checkov static security scanners, mandatory provider `default_tags`/`default_labels` for FinOps traceability, least-privilege IAM, and automated pre-commit hooks.
5. **CI/CD Pipelines & GitOps Workflows (`modern-opentofu-cicd-and-gitops`)**: Passwordless cloud authentication via OpenID Connect (OIDC), multi-stage GitHub Actions / GitLab CI workflows, speculative plan generation (`tofu plan -out=tfplan`) with strict lock timeouts, PR plan summaries with Infracost, manual approval gates, deterministic apply (`tofu apply tfplan`), and scheduled drift detection.
6. **Lifecycle, Refactoring & State Governance (`modern-opentofu-lifecycle-and-drift-governance`)**: Stateful resource safeguards (`prevent_destroy = true`), zero-downtime updates (`create_before_destroy = true`), declarative refactoring with `moved` blocks, safe infrastructure decoupling with OpenTofu 1.7+ `removed` blocks (`lifecycle { destroy = false }`), declarative `import` blocks, state disaster recovery, and living runbooks.

---

## Specialized Skills Index

| Skill Name | Core Competencies | Primary Artifacts |
| :--- | :--- | :--- |
| [`modern-opentofu-modular-architecture`](skills/modern-opentofu-modular-architecture/) | Canonical file decomposition, OpenTofu registry pinning, object typing, early variable evaluation, dynamic providers. | `variables.tf`, `versions.tf`, `outputs.tf`, `terraform-docs` |
| [`modern-opentofu-state-encryption-and-backends`](skills/modern-opentofu-state-encryption-and-backends/) | OpenTofu 1.7+ native encryption (AES-GCM, KMS, PBKDF2), remote backends with distributed state locking, blast-radius segmentation. | `encryption.tofu`, S3+DynamoDB backend, Azure Blob backend |
| [`modern-opentofu-testing-and-mocking`](skills/modern-opentofu-testing-and-mocking/) | Native `tofu test` engine, OpenTofu 1.8+ `mock_provider` credential-free unit tests, plan assertions, negative validations. | `tests/*.tftest.hcl` |
| [`modern-opentofu-security-and-quality-gates`](skills/modern-opentofu-security-and-quality-gates/) | Pre-flight validation, `.tflint.hcl` linting, Trivy security scanning, provider `default_tags` for FinOps, `.pre-commit-config.yaml`. | `.tflint.hcl`, `.pre-commit-config.yaml`, provider configs |
| [`modern-opentofu-cicd-and-gitops`](skills/modern-opentofu-cicd-and-gitops/) | Passwordless OIDC authentication (AWS, Azure, GCP), deterministic plan/apply separation, PR plan comments, scheduled drift checks. | GitHub Actions workflows, GitLab CI blueprints |
| [`modern-opentofu-lifecycle-and-drift-governance`](skills/modern-opentofu-lifecycle-and-drift-governance/) | `prevent_destroy`, `create_before_destroy`, surgical `ignore_changes`, declarative `moved`/`removed`/`import` blocks, state recovery. | Lifecycle configs, refactoring blocks, disaster recovery runbooks |

---

## Non-Negotiable Guardrails (Absolute Invariants)

1. **Standard Modular File Decomposition & Version Pinning**:
   - Monolithic single-file configurations are strictly prohibited. Every module and root environment must decouple concerns into standard files: `versions.tf`, `providers.tf`, `variables.tf`, `outputs.tf`, and domain-specific `main.tf` / resource files.
   - Root and child modules must explicitly declare semantic version constraints in `versions.tf` (`required_version = ">= 1.8.0, < 2.0.0"`) and pin all providers to explicit source registries (`registry.opentofu.org` or upstream mirrors) and semantic versions (`~> 5.0`).

2. **Strict Typing, Custom Validation & Nullable Constraints**:
   - Variables must never use untyped `any` or ambiguous primitive wrappers when defining complex structures. Mandate explicit `type = object({ ... })` schemas.
   - Every input variable must define an informative `description`.
   - Variables with domain invariants must declare `validation { condition = ... error_message = "..." }` blocks with descriptive error feedback.
   - Sensitive inputs (passwords, tokens, private keys) must declare `sensitive = true`. Non-optional variables must declare `nullable = false`.

3. **Mandatory Native State & Plan Encryption (OpenTofu 1.7+)**:
   - Storing sensitive values in unencrypted state files is strictly prohibited. Production codebases must declare OpenTofu native `encryption` blocks configured with authenticated encryption (e.g. `aes_gcm` method with 256-bit keys) and secure key providers (`pbkdf2` via environment passphrase, `aws_kms`, `gcp_kms`, `azure_keyvault`, or `openbao`).
   - Both `state` and `plan` targets must be encrypted (`state { method = ... enforced = true }` and `plan { method = ... enforced = true }`) to prevent credential leakage in CI/CD pipeline artifacts and remote storage buckets.

4. **Blast-Radius State Segmentation & Remote Backend Locking**:
   - Storing an entire cloud infrastructure footprint in a single monolithic state file is strictly forbidden. Segment state files by environmental tier (`prod`, `staging`, `dev`) and architectural layer (`network-foundation`, `data-persistence`, `compute-cluster`, `workload-apps`).
   - Remote backends must always enforce distributed state locking (e.g., S3 backend with DynamoDB locking or native S3 locking, Azure Blob Storage with lease lock, GCS object locking).
   - Cross-state dependencies must avoid exposing broad credentials; prefer direct secret and parameter store references (SSM Parameter Store, Key Vault, Vault) over untyped `tofu_remote_state` data sources.

5. **Shift-Left Testing with Native `tofu test` & Mocking**:
   - Every production module must ship with automated tests under `tests/` using native `*.tftest.hcl` test suites.
   - Unit tests must leverage OpenTofu 1.8+ `mock_provider` declarations and resource/data overrides (`override_resource`, `override_data`, `override_module`) to execute lightning-fast syntactic and policy assertions in CI without requiring cloud credentials or incurring billing costs.
   - Test suites must validate edge cases and assert expected error handling using `expect_failures` blocks.

6. **Resource Lifecycle Guardrails (`prevent_destroy` & `create_before_destroy`)**:
   - Stateful and mission-critical resources (relational databases, production NoSQL clusters, primary object storage buckets, production VPCs/VNets) must declare `lifecycle { prevent_destroy = true }` to guarantee immunity against accidental deletion.
   - Compute resources, load balancer listeners, and security associations undergoing continuous updates must declare `lifecycle { create_before_destroy = true }` to ensure zero-downtime blue/green rollouts.
   - Never use blanket wildcard `lifecycle { ignore_changes = all }`; target only specific, dynamically updated attributes (e.g. `tags["LastModified"]`, auto-scaling capacities).

7. **Declarative Refactoring over Imperative State Surgery**:
   - Direct destructive manual CLI state surgery (`tofu state rm`, `tofu state mv`) in CI/CD pipelines is strictly prohibited.
   - Renaming or refactoring modules and resources must use declarative `moved { from = ... to = ... }` blocks committed to version control.
   - Removing resources from OpenTofu management without destroying cloud infrastructure must use OpenTofu 1.7+ declarative `removed { from = ... lifecycle { destroy = false } }` blocks.
   - Adopting existing resources into code must use declarative `import { to = ... id = ... }` blocks with automated configuration generation (`tofu plan -generate-config-out=...`).

8. **Zero-Secret CI/CD with OIDC & Deterministic Plan-Apply Separation**:
   - Automated CI/CD pipelines must authenticate to cloud providers using passwordless OpenID Connect (OIDC) federation (AWS IAM AssumeRoleWithWebIdentity, Azure Federated Identity, GCP Workload Identity). Storing static long-lived cloud credentials in repository secrets is strictly prohibited.
   - Pipelines must enforce deterministic execution: PR workflows generate an encrypted speculative plan artifact (`tofu plan -out=tfplan -lock-timeout=5m`), publish an automated diff summary and FinOps cost estimation to the pull request, and deployment jobs execute `tofu apply tfplan` strictly against the generated plan artifact.

9. **Quality Gates, Linter Enforcement & FinOps Governance**:
   - All code submitted to version control must pass `tofu fmt -check -recursive`, `tofu validate`, TFLint (`.tflint.hcl` with cloud rulesets), and Trivy/Checkov static security scanners.
   - Provider declarations must declare standardized `default_tags` / `default_labels` (e.g., `Environment`, `Project`, `ManagedBy = "OpenTofu"`, `CostCenter`, `Owner`) to guarantee cost allocation and resource traceability across all managed cloud infrastructure.

10. **The Living `README.md` Runbook Mandate**:
    - Every module and root environment repository must maintain a comprehensive, synchronized `README.md` generated via `terraform-docs`.
    - Documentation must include architectural topologies, input/output contract tables, provider dependencies, prerequisite setup, and operational disaster recovery runbooks (including state unlock procedures and key rotation runbooks).

---

## Quick Start Example: Native State Encryption (OpenTofu 1.7+)

Create `encryption.tofu.hcl`:

```hcl
terraform {
  encryption {
    key_provider "aws_kms" "primary" {
      kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/your-key-uuid"
      region     = "us-east-1"
      key_spec   = "AES_256"
    }

    method "aes_gcm" "state_method" {
      keys = key_provider.aws_kms.primary
    }

    state {
      method   = method.aes_gcm.state_method
      enforced = true
    }

    plan {
      method   = method.aes_gcm.state_method
      enforced = true
    }
  }
}
```

Initialize and plan:

```bash
tofu init
tofu plan -out=tfplan
```

Your state file and speculative plan are now cryptographically secured using 256-bit AES-GCM envelope encryption.

---

## Quick Start Example: Mocked Unit Test (OpenTofu 1.8+)

Create `tests/unit.tftest.hcl`:

```hcl
mock_provider "aws" {
  mock_resource "aws_vpc" {
    defaults = {
      id  = "vpc-mock12345"
      arn = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-mock12345"
    }
  }
}

run "verify_vpc_mocked" {
  command = plan

  assert {
    condition     = output.vpc_id == "vpc-mock12345"
    error_message = "Mocked VPC ID did not match."
  }
}
```

Run test without cloud credentials:

```bash
tofu test
```

---

## License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

Copyright (c) 2026 [Halcyon Tech](https://github.com/HalcyonTech-LTDA).
