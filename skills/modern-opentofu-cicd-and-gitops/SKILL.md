---
name: modern-opentofu-cicd-and-gitops
description: >-
  Use this skill when designing, building, or troubleshooting OpenTofu CI/CD pipelines and GitOps workflows:
  passwordless cloud authentication via OIDC (AWS IAM Role, Azure Federated Identity, GCP Workload Identity),
  multi-stage validation (fmt, validate, tflint, trivy), unit testing with provider mocking (tofu test),
  speculative plan generation (tofu plan -out=tfplan) with strict lock timeouts, PR plan summaries,
  manual approval gates, deterministic apply (tofu apply tfplan), and scheduled drift detection.
---

# Modern OpenTofu CI/CD Pipelines & GitOps Workflows

This skill provides comprehensive pipeline blueprints, security patterns, and GitOps workflows for deploying OpenTofu infrastructure in automated CI/CD environments.

---

## Core Engineering Principles

1. **Passwordless Cloud Authentication via OIDC**:
   - Storing long-lived cloud credentials (such as `AWS_ACCESS_KEY_ID` or Azure service principal client secrets) inside GitHub Secrets is an anti-pattern.
   - Use OpenID Connect (OIDC) federation:
     - **AWS**: Configure IAM OpenID Connect Identity Provider for GitHub Actions and assume role with `aws-actions/configure-aws-credentials`.
     - **Azure**: Configure Federated Identity Credentials on User-Assigned Managed Identities.
     - **GCP**: Configure Workload Identity Federation pools.

2. **Strict Plan-Apply Separation**:
   - Never run `tofu apply` without a pre-computed plan.
   - PR workflows generate an encrypted plan artifact:
     ```bash
     tofu plan -out=tfplan -lock-timeout=5m
     ```
   - Deployment workflows execute strictly against the plan artifact:
     ```bash
     tofu apply -lock-timeout=10m tfplan
     ```
   - This ensures that what was reviewed in the pull request is exactly what gets applied to production.

3. **PR Feedback & FinOps Transparency**:
   - CI runners post speculative plan summaries to pull requests, highlighting additions (`+`), changes (`~`), and destructions (`-`).
   - Run Infracost to post cost delta breakdowns directly into the PR review thread.

4. **Automated Drift Detection**:
   - Out-of-band manual changes in the cloud console cause state drift.
   - Run scheduled headless drift detection workflows (e.g. daily cron):
     ```bash
     tofu plan -detailed-exitcode -lock=false
     ```
   - Exit code `0` = No changes; exit code `2` = Drift detected (triggers alerting to Slack/Teams/PagerDuty).

5. **Concurrency & Lock Contention Management**:
   - Prevent simultaneous pipeline runs from corrupting state or failing on locks.
   - Enforce GitHub Actions `concurrency` groups keyed to the target environment:
     ```yaml
     concurrency:
       group: opentofu-${{ inputs.environment }}
       cancel-in-progress: false
     ```

---

## Directory Resources & References

- **Detailed Guides**:
  - [Passwordless OIDC Authentication Blueprint](./references/oidc_passwordless_authentication.md)
  - [GitHub Actions Pipeline Architecture](./references/github_actions_pipeline_blueprint.md)
  - [State Locking & Drift Detection Governance](./references/state_locking_and_drift_detection.md)
- **Reference Implementations**:
  - [Production GitHub Actions OpenTofu Workflow](./examples/github-actions-opentofu-ci-cd.yml)
  - [Scheduled Drift Detection Workflow](./examples/github-actions-drift-detection.yml)
  - [GitLab CI Pipeline Blueprint](./examples/gitlab-ci-opentofu.yml)
