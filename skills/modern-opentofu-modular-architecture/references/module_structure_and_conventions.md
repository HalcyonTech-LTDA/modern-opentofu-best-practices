# OpenTofu Module Structure & File Conventions

A standardized module structure ensures predictable maintenance, effortless onboarding, and deterministic CI/CD behavior across multi-cloud infrastructure codebases.

---

## Canonical File Hierarchy

Every child module and root deployment stack must adhere to the standard file layout:

```text
my-module/
├── versions.tf          # Core required_version and required_providers constraints
├── providers.tf         # Provider configurations and alias mappings
├── variables.tf         # Input variable declarations with types, validations, and defaults
├── outputs.tf           # Exported module attributes with explicit descriptions
├── main.tf              # Primary entrypoint and core resource orchestrations
├── subnets.tf           # Domain-partitioned resources (split when main.tf exceeds ~150 lines)
├── security.tf          # Domain-partitioned network/IAM security controls
├── locals.tf            # Calculated values, transformed maps, and standardized tag sets
├── README.md            # Generated living documentation via terraform-docs
├── examples/            # Minimal and complete reference usage examples
│   ├── basic/
│   └── complete/
└── tests/               # Native OpenTofu test suites
    ├── unit.tftest.hcl
    └── integration.tftest.hcl
```

---

## versions.tf Specifications

Pin both the OpenTofu core version and provider versions explicitly:

```hcl
terraform {
  required_version = ">= 1.8.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Resolved natively by registry.opentofu.org
      version = "~> 5.50"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
```

### Best Practices:
- Always use the pessimistic constraint operator (`~>`) to permit backwards-compatible patch and minor releases while preventing breaking major version upgrades.
- In child modules, specify a range of supported provider versions (e.g. `>= 5.0, < 6.0`) to give root configurations flexibility.
- In root deployment configurations, pin providers to specific minor versions (`~> 5.50.0`).

---

## outputs.tf Guidelines

Outputs define the public contract of your module. They should be clean, intentional, and strictly documented:

```hcl
output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The unique identifier of the provisioned Virtual Private Cloud (VPC)."
}

output "private_subnet_ids" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "List of IDs for all private tier subnets across availability zones."
}

output "database_credentials" {
  value       = {
    username = aws_db_instance.primary.username
    password = aws_db_instance.primary.password
    endpoint = aws_db_instance.primary.endpoint
  }
  description = "Master database credentials and connection endpoint."
  sensitive   = true # Crucial: hides sensitive fields in stdout / CLI logs
}
```

### Invariants:
1. Always include a non-empty `description`.
2. Always apply `sensitive = true` if the output contains secrets, connection strings, or private tokens.
3. Export structured attributes or collections (e.g. `map` or `list`) rather than dumping raw raw resource references.
