# State Surgery & Disaster Recovery Runbook

When state files encounter lock deadlocks, metadata corruption, or require critical emergency interventions, follow this standardized runbook.

---

## 1. Inspecting State Safely

Never modify `.tfstate` files manually in a text editor. Use OpenTofu inspection commands:

```bash
# List all resources tracked in the remote state
tofu state list

# Display detailed attributes of a specific resource
tofu state show aws_db_instance.primary

# Pull remote state down locally for read-only inspection (automatically decrypted if native encryption is configured)
tofu state pull > inspected_state.json
```

---

## 2. Emergency State Restoration

If a botched apply or concurrent run corrupts state:

1. **Leverage Backend Versioning**:
   - For S3 backends: Go to AWS S3 Console or run `aws s3api list-object-versions --bucket <bucket> --prefix <key>`.
   - Restore the previous version of `terraform.tfstate`.
2. **Push Restored State**:
   ```bash
   tofu state push restored_state.json
   ```
3. **Run Non-Destructive Refresh**:
   ```bash
   tofu apply -refresh-only
   ```
   This synchronizes OpenTofu's in-memory representation with real cloud provider state without applying any code changes.

---

## 3. Releasing Held Locks

When an apply crashes unexpectedly:

```bash
# 1. Grab Lock ID from error trace
# Example: 8df4a612-4091-88f2-bb01-49b81920ac34

# 2. Release lock cleanly
tofu force-unlock 8df4a612-4091-88f2-bb01-49b81920ac34
```
