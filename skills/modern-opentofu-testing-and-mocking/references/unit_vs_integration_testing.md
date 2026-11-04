# Unit vs Integration Testing Strategies in OpenTofu

Establishing an optimal balance between fast unit tests and thorough integration tests ensures maximum safety without ballooning CI runtimes.

---

## The Testing Pyramid for Infrastructure as Code

```text
       / \
      /   \      Integration Tests (command = apply, real cloud sandbox)
     /  5% \     - Verifies cloud API behavior, IAM permissions, real networking
    /-------\
   /         \   Speculative Plan Tests (command = plan, real provider schema)
  /    25%    \  - Validates full resource graph, inter-resource wiring
 /-------------\
/               \ Unit Tests (mock_provider, overrides, negative tests)
/      70%      \ - Sub-second, zero-cost, runs on every commit/PR
-----------------
```

---

## 1. Unit Testing Strategy

- **When to Use**: On every commit, PR opening, and pre-commit hook.
- **Tools**: `tofu test` with `mock_provider` and `expect_failures`.
- **Target**:
  - Variable validation rules (invalid CIDRs, unsupported regions, short passwords).
  - Calculated locals and conditional expressions (e.g. ternary subnet assignments).
  - Required tags presence.
  - Module outputs contract conformity.

---

## 2. Plan-Based Verification Strategy

- **When to Use**: In PR verification workflows against shared develop/main branches.
- **Tools**: `tofu test` with `command = plan` using read-only cloud credentials (or mocked data sources).
- **Target**:
  - Provider schema validation (e.g., verifying that instance types and AMIs exist).
  - Dependency graph DAG resolution.

---

## 3. Integration Testing Strategy

- **When to Use**: Nightly builds, release candidate tags, or major module refactors.
- **Tools**: `tofu test` with `command = apply` deployed into an isolated ephemeral sandbox AWS Account / Azure Subscription.
- **Target**:
  - Live resource creation.
  - HTTPS connectivity probes.
  - End-to-end secret retrieval and database schema migrations.
  - Automatic cleanup validation.
