# Native `tofu test` Framework Architecture

Modern OpenTofu includes an integrated testing harness executing declarative test files (`*.tftest.hcl`) directly against module configurations.

---

## 1. Test File Structure & Semantics

Test suites reside inside a `tests/` subdirectory or directly within the root of a module:

```text
my-module/
├── main.tf
├── variables.tf
├── outputs.tf
└── tests/
    ├── 01_unit_validations.tftest.hcl
    └── 02_integration_plan.tftest.hcl
```

Inside a `.tftest.hcl` file, tests are structured using ordered `run` blocks:

```hcl
# tests/01_unit_validations.tftest.hcl

# Global variables applied to all runs
variables {
  environment = "dev"
  project     = "unit-test-proj"
}

run "verify_default_configuration" {
  command = plan

  assert {
    condition     = output.vpc_id != ""
    error_message = "VPC ID output must not be empty after plan."
  }
}

run "verify_custom_tags" {
  command = plan

  variables {
    tags = {
      Owner = "PlatformTeam"
    }
  }

  assert {
    condition     = aws_vpc.this.tags["Owner"] == "PlatformTeam"
    error_message = "Custom tags were not properly propagated to the VPC resource."
  }
}
```

---

## 2. Test Execution Modes

### Plan Mode (`command = plan`)
- Default mode if not specified.
- Runs `tofu plan` in memory, evaluating all variables, locals, expressions, and resource configurations.
- Does not call cloud APIs to mutate resources.
- Fastest feedback loop (ideal for CI PR checks).

### Apply Mode (`command = apply`)
- Deploys real infrastructure.
- Tests post-provisioning attributes (e.g. public IPs, DNS resolution, endpoint accessibility).
- Automatically invokes `tofu destroy` when the test finishes (even if assertions fail), guaranteeing no orphaned cloud assets.

---

## 3. CLI Invocations & Options

```bash
# Run all tests in the module
tofu test

# Run tests in a specific directory or file
tofu test -test-directory=tests/
tofu test tests/01_unit_validations.tftest.hcl

# Filter runs by variable input
tofu test -var="environment=staging"

# High concurrency
tofu test -parallelism=8

# JSON output for automated CI reporting / test dashboard
tofu test -json > test-results.json
```
