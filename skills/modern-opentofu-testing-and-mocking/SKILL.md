---
name: modern-opentofu-testing-and-mocking
description: >-
  Use this skill when authoring, structuring, or running OpenTofu tests:
  native tofu test command, tests/*.tftest.hcl test suites, provider mocking (mock_provider)
  and resource/data overrides (override_resource, override_data) for zero-cost credential-free unit testing,
  plan-based assertions (command = plan), ephemeral apply tests (command = apply),
  custom assertion conditions, and negative validation testing with expect_failures.
---

# Modern OpenTofu Shift-Left Testing & Mocking Framework

This skill provides comprehensive architectural patterns and testing methodologies for validating OpenTofu modules and environments using native `tofu test`, OpenTofu 1.8+ provider mocking, and assertions.

---

## Core Engineering Principles

1. **Native `tofu test` Framework**:
   - Modern OpenTofu deprecates heavy external testing wrappers (Terratest, Kitchen-Terraform) in favor of the native `tofu test` engine.
   - Tests reside in `tests/*.tftest.hcl` alongside modules and execute declaratively.

2. **Credential-Free Unit Testing with Provider Mocking (OpenTofu 1.8+)**:
   - OpenTofu 1.8 introduced `mock_provider`, enabling deep unit testing without cloud credentials, zero network calls, and zero cloud spend.
   - Combine `mock_provider` with `override_resource`, `override_data`, and `override_module` to inject simulated cloud responses into the dependency graph.

3. **Plan-Based Fast Assertions (`command = plan`)**:
   - Run speculative tests that validate HCL logic, variable interpolations, string calculations, and module outputs during the planning stage without spinning up real infrastructure:
     ```hcl
     run "validate_subnet_calculations" {
       command = plan

       assert {
         condition     = length(output.private_subnet_ids) == 2
         error_message = "Expected exactly two private subnets for multi-AZ topology."
       }
     }
     ```

4. **Integration Testing with Ephemeral Environments (`command = apply`)**:
   - Execute integration runs that deploy real resources into isolated sandbox accounts/subscriptions and automatically tear them down upon completion.

5. **Negative Testing & Invariant Validation (`expect_failures`)**:
   - Ensure invalid variable inputs are rejected by module validations:
     ```hcl
     run "reject_invalid_cidr" {
       command = plan

       variables {
         cidr_block = "not-a-valid-cidr"
       }

       expect_failures = [
         var.cidr_block
       ]
     }
     ```

6. **Parallel Test Execution**:
   - Execute test suites concurrently via `tofu test -parallelism=8` for sub-second CI validation feedback loops.

---

## Directory Resources & References

- **Detailed Guides**:
  - [Native tofu test Framework Guide](./references/tofu_test_framework.md)
  - [Provider Mocking & Overrides Guide](./references/provider_mocking_and_overrides.md)
  - [Unit vs Integration Testing Strategies](./references/unit_vs_integration_testing.md)
- **Reference Implementations**:
  - [Mocked Unit Test Blueprint](./examples/unit_test_mocked.tftest.hcl)
  - [Plan-Based Verification Suite](./examples/integration_test_plan.tftest.hcl)
  - [Negative Validation Test Suite](./examples/negative_validation.tftest.hcl)
