---
description: >-
  Automatically enforces modern OpenTofu engineering standards: modular architecture & OpenTofu registry pinning,
  native state and plan encryption (AES-GCM / PBKDF2 / KMS / Azure Key Vault / GCP KMS / OpenBao), early variable evaluation,
  remote backend state locking, shift-left testing with native 'tofu test' (provider mocking, resource overrides, assertions),
  TFLint & Trivy security quality gates, passwordless OIDC CI/CD GitOps pipelines, resource lifecycle controls (prevent_destroy, moved, removed, import),
  and living README.md runbook documentation.
trigger: model_decision
---

# Modern OpenTofu Engineering Guardrails & Skill Router

When authoring, reviewing, refactoring, testing, or deploying cloud infrastructure using OpenTofu, strictly adhere to Modern OpenTofu Engineering Standards and the corresponding specialized skills:

| When working on... | Consult & Activate Skill | Key Focus Areas |
| :--- | :--- | :--- |
| **Modular Architecture & Contracts** | `modern-opentofu-modular-architecture` | Standard file decomposition (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`), registry distribution (`registry.opentofu.org`), strict typing & validation blocks, early variable evaluation, dynamic providers, and living docs via `terraform-docs`. |
| **State Encryption & Remote Backends** | `modern-opentofu-state-encryption-and-backends` | OpenTofu native state & plan encryption (`encryption` blocks with AES-GCM and PBKDF2 / AWS KMS / Azure Key Vault / GCP KMS / OpenBao), remote backend leasing/locking (S3 + DynamoDB, Azure Blob, GCS), blast-radius state segmentation, and zero secret leakage. |
| **Testing, Mocking & Assertions** | `modern-opentofu-testing-and-mocking` | Shift-left native `tofu test` suites (`tests/*.tftest.hcl`), OpenTofu 1.8+ credential-free unit testing with `mock_provider` and `override_resource`, integration testing with ephemeral fixtures, custom assertion rules, and negative testing (`expect_failures`). |
| **Security, Static Analysis & Quality Gates** | `modern-opentofu-security-and-quality-gates` | Formatting (`tofu fmt -check -recursive`), strict validation (`tofu validate`), `.tflint.hcl` rulesets, Trivy/Checkov vulnerability scans, mandatory provider `default_tags`/`default_labels`, least-privilege IAM, and pre-commit automation. |
| **CI/CD Pipelines & GitOps Workflows** | `modern-opentofu-cicd-and-gitops` | Passwordless cloud authentication via OpenID Connect (OIDC), multi-stage GitHub Actions / GitLab CI workflows, speculative plans (`tofu plan -out=tfplan`) with `-lock-timeout=5m`, PR plan diff summaries, approval gates, deterministic apply (`tofu apply tfplan`), and scheduled drift detection. |
| **Lifecycle, Refactoring & Drift Governance** | `modern-opentofu-lifecycle-and-drift-governance` | Stateful resource safeguards (`prevent_destroy = true`), zero-downtime updates (`create_before_destroy = true`), declarative refactoring with `moved` and `removed` blocks (`lifecycle { destroy = false }`), declarative `import` blocks, state disaster recovery, and living runbooks. |

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
   - Pipelines must enforce deterministic execution: PR workflows generate an encrypted speculative plan artifact (`tofu plan -out=tfplan -lock-timeout=5m`), publish an automated diff summary and FinOps cost estimation to the pull request, and deployment jobs execute `tofu apply tfplan` strictly against the reviewed artifact without recalculating the plan.

9. **Quality Gates, Linter Enforcement & FinOps Governance**:
   - All code submitted to version control must pass `tofu fmt -check -recursive`, `tofu validate`, TFLint (`.tflint.hcl` with cloud rulesets), and Trivy/Checkov static security scanners.
   - Provider declarations must declare standardized `default_tags` / `default_labels` (e.g., `Environment`, `Project`, `ManagedBy = "OpenTofu"`, `CostCenter`, `Owner`) to guarantee cost allocation and resource traceability across all managed cloud infrastructure.

10. **The Living `README.md` Runbook Mandate**:
    - Every module and root environment repository must maintain a comprehensive, synchronized `README.md` generated via `terraform-docs`.
    - Documentation must include architectural topologies, input/output contract tables, provider dependencies, prerequisite setup, and operational disaster recovery runbooks (including state unlock procedures and key rotation runbooks).

Consult the corresponding specialized skills for complete technical deep dives, configuration blueprints, reference architectures, and operational runbooks.
