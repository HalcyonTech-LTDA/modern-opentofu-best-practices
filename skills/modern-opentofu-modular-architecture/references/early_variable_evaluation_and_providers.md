# Early Variable Evaluation & Dynamic Providers in OpenTofu

OpenTofu introduces substantial advancements in configuration ergonomics that eliminate legacy Terraform workarounds (such as Terragrunt, Makefiles, or wrapper bash scripts) through **Early Variable Evaluation** (introduced in OpenTofu 1.8) and **Dynamic Provider Iteration**.

---

## 1. Early Variable Evaluation (OpenTofu 1.8+)

Historically, input variables could not be referenced inside `backend` blocks, provider blocks, or module `source` arguments because variables were only evaluated during the graph execution phase (after `init`).

In OpenTofu 1.8+, variables can be passed to `tofu init` via `-var` or `-var-file`, enabling dynamic backend and provider configuration natively:

### Backend Parameterization with Variables

```hcl
# versions.tf
terraform {
  required_version = ">= 1.8.0, < 2.0.0"

  backend "s3" {
    bucket         = var.state_bucket_name
    key            = "workloads/${var.environment}/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.state_lock_table
    encrypt        = true
  }
}
```

Initializing with early variables:

```bash
tofu init \
  -var="environment=production" \
  -var="aws_region=us-east-1" \
  -var="state_bucket_name=corp-opentofu-states-us-east-1" \
  -var="state_lock_table=corp-opentofu-locks"
```

### Module Source Parameterization

Variables can also dynamically specify module versions and paths during initialization:

```hcl
module "network" {
  source  = "git::https://github.com/HalcyonTech-LTDA/terraform-aws-vpc.git?ref=${var.vpc_module_version}"
  # ...
}
```

---

## 2. Dynamic Provider Iteration (`for_each` in Providers)

OpenTofu allows you to generate multiple provider aliases iteratively using `for_each`:

```hcl
# providers.tf
locals {
  regions = toset([
    "us-east-1",
    "us-west-2",
    "eu-west-1"
  ])
}

provider "aws" {
  for_each = local.regions
  alias    = each.key
  region   = each.value

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "OpenTofu"
      Region      = each.value
    }
  }
}
```

### Passing Dynamic Providers to Modules

You can route each aliased provider into instantiated modules:

```hcl
module "regional_monitoring" {
  for_each = local.regions
  source   = "./modules/regional-monitor"

  providers = {
    aws = aws[each.key]
  }

  region_name = each.value
}
```

---

## 3. Provider-Defined Functions

OpenTofu supports provider-defined functions (functions contributed directly by provider plugins). This removes the need for empty `data` source hacks or awkward local-exec workarounds for simple data transformations, cryptographic operations, or provider-native hashing.
