---
name: modern-opentofu-modular-architecture
description: >-
  Use this skill when designing, authoring, reviewing, or refactoring OpenTofu modules:
  standard file layout, semantic version constraints, OpenTofu registry pinning, strict typing
  with object schemas, custom validation blocks with descriptive errors, early variable evaluation
  in backend and provider configurations (OpenTofu 1.8+), dynamic provider declarations with for_each,
  provider-defined functions, module outputs design, and automated living documentation via terraform-docs.
---

# Modern OpenTofu Modular Architecture & Engineering Contracts

This skill provides comprehensive architectural patterns, typing standards, and design principles for authoring reusable, enterprise-grade OpenTofu modules and composing robust root configurations.

---

## Core Engineering Principles

1. **Standard Modular File Decomposition**:
   - Every module (child and root) must maintain a deterministic file layout:
     - `versions.tf`: OpenTofu core version constraints and `required_providers` definitions.
     - `variables.tf`: Explicit input parameters with strict types, descriptions, validations, and default values.
     - `outputs.tf`: Exported attributes with descriptions and sensitive flags.
     - `providers.tf`: Provider instantiation and root configuration blocks.
     - `main.tf`: Core resource orchestrations, delegating sub-components to logical domain files (e.g. `subnets.tf`, `routing.tf`, `security.tf`) as complexity grows.
     - `README.md`: Up-to-date living documentation formatted according to `terraform-docs`.

2. **OpenTofu Version & Provider Source Pinning**:
   - Always declare modern OpenTofu core version constraints:
     ```hcl
     terraform {
       required_version = ">= 1.8.0, < 2.0.0"
       required_providers {
         aws = {
           source  = "opentofu/aws" # Or "hashicorp/aws" proxied through registry.opentofu.org
           version = "~> 5.50"
         }
       }
     }
     ```
   - Target the official OpenTofu Registry (`registry.opentofu.org`).

3. **Strict Typing, Custom Validation & Nullable Constraints**:
   - Ban untyped `any` or loose maps without schema definitions.
   - Use structured `type = object({ ... })` for nested configuration objects.
   - Define custom `validation { ... }` blocks with clear, actionable `error_message` strings:
     ```hcl
     variable "environment" {
       type        = string
       description = "Target deployment environment tier."
       nullable    = false

       validation {
         condition     = contains(["dev", "staging", "prod"], var.environment)
         error_message = "The environment must be one of: 'dev', 'staging', or 'prod'."
       }
     }
     ```
   - Mark credentials, tokens, and keys with `sensitive = true`.

4. **Early Variable Evaluation (OpenTofu 1.8+)**:
   - Leverage OpenTofu 1.8's capability to evaluate input variables early during `tofu init` and configuration parsing.
   - Use variables directly in backend blocks, provider configurations, and module source URLs without needing repetitive external tooling or script wrappers.

5. **Dynamic Provider Declarations & Iteration**:
   - OpenTofu supports iterating over providers dynamically:
     ```hcl
     # Modern OpenTofu provider iteration pattern
     provider "aws" {
       for_each = toset(["us-east-1", "eu-west-1"])
       alias    = each.value
       region   = each.value
     }
     ```

6. **Composable Interface Pattern (Flat Modularity)**:
   - Avoid deep child-module nesting (e.g., Module A -> Module B -> Module C). High hierarchy depth creates rigid dependency coupling and obscures plan diffs.
   - Favor flat, composable modules where the root module acts as an orchestrator, wiring outputs of foundation modules into inputs of downstream workload modules.

---

## Directory Resources & References

- **Detailed Guides**:
  - [Module Structure & File Conventions](./references/module_structure_and_conventions.md)
  - [Early Variable Evaluation & Dynamic Providers](./references/early_variable_evaluation_and_providers.md)
  - [Strict Typing, Validation & Contracts](./references/typing_and_validation.md)
- **Reference Implementations**:
  - [VPC Child Module Example](./examples/vpc-child-module/)
  - [Root Composition Example](./examples/root-composition/)
