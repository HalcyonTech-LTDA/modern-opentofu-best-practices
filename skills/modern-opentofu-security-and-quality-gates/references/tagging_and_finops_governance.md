# Standardized Tagging & FinOps Governance in OpenTofu

Consistent tagging across all cloud resources is the foundation of FinOps cost allocation, showback/chargeback reporting, automated lifecycle sweeps, and ownership accountability.

---

## 1. Provider-Level Default Tags

Rather than manually appending tags in every resource block, declare standard tags globally at the provider level using `default_tags`:

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment        = var.environment
      Project            = var.project_name
      ManagedBy          = "OpenTofu"
      Repository         = "HalcyonTech-LTDA/core-infrastructure"
      CostCenter         = var.cost_center
      DataClassification = var.data_classification
    }
  }
}
```

Every resource created by this provider automatically inherits these tags in AWS.

---

## 2. Resource-Level Custom Tags Merge

When individual resources require specialized tags (such as Kubernetes cluster ownership or auto-scaling tags), merge them with local variables:

```hcl
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-sg-"
  vpc_id      = var.vpc_id

  tags = merge(
    var.custom_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb-sg"
      Role = "IngressProxy"
    }
  )
}
```

---

## 3. FinOps Integration in Pull Requests (Infracost)

Modern GitOps pipelines evaluate cost implications before merging code:

```bash
# Generate cost breakdown of speculative plan
infracost breakdown --path tfplan.json --format json --out-file infracost.json

# Post cost diff comment to GitHub PR
infracost comment github --path infracost.json --repo $GITHUB_REPOSITORY --pull-request $PR_NUMBER
```
