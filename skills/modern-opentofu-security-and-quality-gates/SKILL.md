---
name: modern-opentofu-security-and-quality-gates
description: >-
  Use this skill when auditing, hardening, or establishing quality gates for OpenTofu codebases:
  canonical code formatting (tofu fmt), syntax validation (tofu validate), TFLint rulesets (.tflint.hcl),
  static security scanning (Trivy, Checkov, tfsec), zero hardcoded secrets policies,
  mandatory provider default_tags / default_labels for FinOps traceability, least-privilege IAM,
  and automated pre-commit hooks.
---

# Modern OpenTofu Security Hardening & Quality Gates

This skill provides comprehensive quality gates, static code analysis rules, and security controls for OpenTofu infrastructure codebases.

---

## Core Engineering Principles

1. **Shift-Left Static Analysis**:
   - Catch configuration defects, deprecated syntax, and policy violations in milliseconds before planning against real cloud APIs.
   - Enforce four sequential pre-flight gates:
     1. `tofu fmt -check -recursive`: Enforces deterministic whitespace and indentation formatting.
     2. `tofu validate`: Verifies syntax and internal consistency against provider schemas.
     3. `tflint --config=.tflint.hcl`: Enforces naming conventions, module structures, and cloud-provider-specific best practices.
     4. `trivy config .` / `checkov -d .`: Detects security misconfigurations, overly permissive IAM policies, and unencrypted datastores.

2. **Mandatory Standardized Tagging & FinOps (`default_tags`)**:
   - Unallocated cloud resources lead to cost leaks and untracked assets.
   - Root provider definitions must configure `default_tags` (AWS) or `default_labels` (GCP) containing:
     - `Environment`: Deployment tier (`dev`, `staging`, `prod`).
     - `Project`: Project or subsystem name.
     - `ManagedBy`: "OpenTofu".
     - `CostCenter`: Business unit cost allocation code.
     - `Owner`: Team email or repository URL.

3. **Zero Hardcoded Secrets Policy**:
   - Hardcoded database passwords, API tokens, and private keys in `.tf` files or unencrypted `.tfvars` are strictly prohibited.
   - Inject secrets dynamically via cloud secret managers (AWS Secrets Manager, Azure Key Vault, HashiCorp Vault) or ephemeral environment variables in CI runners.

4. **Least-Privilege Security Posture by Default**:
   - Prohibit wildcard IAM permissions (`"Action": "*"`).
   - Require TLS 1.2+ minimum on all web endpoints, load balancers, and storage accounts.
   - Enforce encryption-at-rest with KMS Customer Managed Keys on all persistent datastores.
   - Restrict network ingress to private endpoints and internal subnets.

5. **Pre-Commit Automation**:
   - Prevent substandard code or secret commits from entering source control by binding quality checks to git hooks using `.pre-commit-config.yaml`.

---

## Directory Resources & References

- **Detailed Guides**:
  - [TFLint Configuration & Static Analysis Rules](./references/tflint_and_static_analysis.md)
  - [Security Hardening & Scanner Integration](./references/security_scanning_and_hardening.md)
  - [Standardized Tagging & FinOps Governance](./references/tagging_and_finops_governance.md)
- **Reference Implementations**:
  - [Enterprise .tflint.hcl Ruleset](./examples/.tflint.hcl)
  - [Automated .pre-commit-config.yaml Hook](./examples/.pre-commit-config.yaml)
  - [Provider Default Tags Blueprint](./examples/provider-default-tags.tf)
