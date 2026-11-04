---
name: modern-opentofu-lifecycle-and-drift-governance
description: >-
  Use this skill when managing resource lifecycles, performing declarative code refactoring,
  safely unmanaging or importing infrastructure, and running disaster recovery:
  lifecycle meta-arguments (prevent_destroy, create_before_destroy, surgical ignore_changes),
  declarative moved blocks for zero-downtime refactors, declarative removed blocks (OpenTofu 1.7+)
  to decouple resources without destroying cloud assets, declarative import blocks with automatic code generation,
  safe state operations (tofu state list, show, mv, rm), and living README.md runbook documentation.
---

# Modern OpenTofu Lifecycle, Refactoring & State Governance

This skill provides comprehensive operational patterns and configuration standards for resource lifecycles, declarative zero-downtime refactoring, safe infrastructure retirement, and state disaster recovery.

---

## Core Engineering Principles

1. **Stateful Resource Safeguards (`prevent_destroy = true`)**:
   - Accidental deletion of production databases, storage accounts, or persistent disks is irreversible and catastrophic.
   - All stateful resources must declare `lifecycle { prevent_destroy = true }`. OpenTofu rejects any plan attempting to destroy or recreate protected resources.

2. **Zero-Downtime Replacements (`create_before_destroy = true`)**:
   - By default, OpenTofu destroys the existing resource before creating the new one during replacements.
   - For web listeners, compute instances, certificate bindings, and DNS records, declare `lifecycle { create_before_destroy = true }` so the new resource is verified healthy before the old one is terminated.

3. **Surgical `ignore_changes` Discipline**:
   - Prohibit blanket `lifecycle { ignore_changes = all }`.
   - Explicitly enumerate only externally mutated attributes (e.g., auto-scaler capacity counts or dynamically injected system tags):
     ```hcl
     lifecycle {
       ignore_changes = [
         tags["LastScanned"],
         desired_capacity
       ]
     }
     ```

4. **Declarative Refactoring over Manual CLI Surgery**:
   - Renaming or moving resources must never involve error-prone CLI state commands (`tofu state mv`) run manually by operators.
   - Use declarative `moved` blocks committed directly into version control:
     ```hcl
     moved {
       from = aws_instance.legacy_app
       to   = aws_instance.api_gateway
     }
     ```

5. **Safe Infrastructure Decoupling (`removed` block in OpenTofu 1.7+)**:
   - When retiring an OpenTofu module or handing off a cloud resource to another team without deleting the actual cloud asset, use OpenTofu 1.7's `removed` block:
     ```hcl
     removed {
       from = aws_s3_bucket.data_warehouse
       lifecycle {
         destroy = false # Crucial: Removes from state, keeps real bucket intact in AWS!
       }
     }
     ```

6. **Declarative Resource Adoption (`import` block)**:
   - Adopt unmanaged or pre-existing cloud resources into code declaratively with `import`:
     ```hcl
     import {
       to = aws_security_group.ingress
       id = "sg-0123456789abcdef0"
     }
     ```
   - Generate initial HCL definitions automatically via `tofu plan -generate-config-out=generated.tf`.

7. **The Living `README.md` Runbook Mandate**:
   - Every module must maintain an operational runbook detailing disaster recovery, state unlock workflows, and key rotation runbooks.

---

## Directory Resources & References

- **Detailed Guides**:
  - [Resource Lifecycle Governance](./references/resource_lifecycle_governance.md)
  - [Declarative Refactoring (moved, removed, import)](./references/declarative_refactoring_moved_removed_import.md)
  - [State Surgery & Disaster Recovery Runbook](./references/state_surgery_and_disaster_recovery.md)
- **Reference Implementations**:
  - [Lifecycle Rules Configuration](./examples/lifecycle_rules.tf)
  - [Declarative Refactoring Blueprint](./examples/declarative_refactoring.tf)
  - [Declarative Import Blueprint](./examples/declarative_import.tf)
  - [Operational Disaster Recovery Runbook](./examples/runbook_state_disaster_recovery.md)
