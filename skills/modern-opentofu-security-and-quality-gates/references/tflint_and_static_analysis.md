# TFLint & Static Code Analysis for OpenTofu

TFLint is an extensible framework for linting OpenTofu/Terraform code, catching provider-specific misconfigurations, invalid instance types, unpinned modules, and style violations.

---

## 1. Core Rule Enforcement

A modern `.tflint.hcl` should enforce the following standard rules:

- **`terraform_standard_module_structure`**: Verifies that modules adhere to canonical file partitioning.
- **`terraform_naming_convention`**: Enforces strict `snake_case` naming for all resources, data sources, variables, and outputs.
- **`terraform_typed_variables`**: Flags any variable declaration missing an explicit `type`.
- **`terraform_documented_outputs` & `terraform_documented_variables`**: Guarantees that every input and output includes documentation.
- **`terraform_module_pinned_source`**: Mandates that external module references specify explicit versions or commit hashes.
- **`terraform_unused_declarations`**: Detects dead code, unused locals, and unreferenced variables.

---

## 2. Cloud-Specific Ruleset Plugins

In addition to core rules, TFLint provides cloud provider plugins:

```hcl
plugin "aws" {
  enabled = true
  version = "0.38.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

plugin "google" {
  enabled = true
  version = "0.30.0"
  source  = "github.com/terraform-linters/tflint-ruleset-google"
}
```

These provider rulesets catch subtle errors that `tofu validate` misses, such as:
- Invalid EC2 instance types (e.g. `t3.superlarge` typo).
- Unencrypted EBS volumes or S3 buckets.
- Deprecated provider arguments.

---

## 3. Running TFLint in Pipelines

```bash
# Initialize plugins defined in .tflint.hcl
tflint --init

# Run recursive lint check across all submodules
tflint --recursive --minimum-failure-severity=error
```
