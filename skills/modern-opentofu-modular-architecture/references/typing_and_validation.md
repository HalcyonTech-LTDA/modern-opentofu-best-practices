# Strict Typing, Custom Validation & Contracts in OpenTofu

OpenTofu provides expressive type schemas, custom validation blocks, nullable controls, and sensitive markings. Applying them rigorously turns modules into self-documenting, fail-fast engineering contracts.

---

## 1. Object Schemas over Untyped Maps

Avoid loosely typed maps like `type = map(any)` or `type = any`. Define explicit `object({ ... })` schemas with optional fields and default values:

```hcl
variable "network_topology" {
  type = object({
    vpc_cidr            = string
    enable_dns_hostnames = optional(bool, true)
    enable_nat_gateway  = optional(bool, true)
    single_nat_gateway  = optional(bool, false)
    availability_zones  = list(string)
    subnet_tiers = map(object({
      cidr_offsets = list(number)
      tier_type    = string # "public", "private", or "database"
    }))
  })
  description = "Complete network topology specification for the target cluster."
  nullable    = false

  validation {
    condition     = length(var.network_topology.availability_zones) >= 2
    error_message = "Network topology must span at least two availability zones for high availability."
  }
}
```

---

## 2. Advanced Custom Validation Rules

OpenTofu evaluates validation blocks at pre-flight time before cloud provider API calls are made. Leverage regular expressions, CIDR calculations, string functions, and collection tests:

### CIDR Format Validation

```hcl
variable "vpc_cidr" {
  type        = string
  description = "Primary IPv4 CIDR block for the VPC (e.g. 10.0.0.0/16)."
  nullable    = false

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr value must be a valid IPv4 CIDR block (e.g. 10.0.0.0/16)."
  }

  validation {
    condition     = split("/", var.vpc_cidr)[1] >= "16" && split("/", var.vpc_cidr)[1] <= "24"
    error_message = "VPC CIDR mask must be between /16 and /24 to guarantee sufficient IP allocation."
  }
}
```

### Enumeration & Set Validation

```hcl
variable "database_engine_version" {
  type        = string
  description = "Target PostgreSQL engine version."
  default     = "16.3"

  validation {
    condition     = contains(["15.6", "15.7", "16.2", "16.3", "16.4"], var.database_engine_version)
    error_message = "Database engine version must be one of the enterprise-approved LTS versions: 15.6+, 16.2+."
  }
}
```

---

## 3. Sensitive & Nullable Directives

- **`sensitive = true`**: Prevents OpenTofu from printing variable values in plaintext during `tofu plan` or `tofu apply`.
- **`nullable = false`**: Disallows explicitly passing `null`. When a caller attempts to set `var_name = null`, OpenTofu rejects it or falls back to the default value.

```hcl
variable "master_db_password" {
  type        = string
  description = "Master password for the root database administrator user."
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(var.master_db_password) >= 16
    error_message = "Master database password must be at least 16 characters long."
  }
}
```
