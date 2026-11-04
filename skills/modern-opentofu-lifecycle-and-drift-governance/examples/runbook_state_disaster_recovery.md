# Runbook: OpenTofu State Disaster Recovery & Lock Remediation

---

## Scenario A: Releasing Stale State Lock

### Symptoms
CI/CD pipeline fails with:
```text
Error: Error acquiring the state lock
Lock Info:
  ID:        2d75f462-108b-9e12-4211-1200fa45beef
  Path:      halcyon-opentofu-states-us-east-1/workloads/prod/platform.tfstate
  Who:       runner@github-runner-10
  Created:   2026-11-04 09:30:00 UTC
```

### Remediation Steps
1. Verify the runner listed in `Who` has stopped and no other engineer is applying changes.
2. Force-unlock the lock address:
   ```bash
   tofu force-unlock -force 2d75f462-108b-9e12-4211-1200fa45beef
   ```
3. Re-run `tofu plan` to verify state accessibility.

---

## Scenario B: Restoring Corrupted State from S3 Versioning

### Symptoms
`tofu plan` fails with state parse errors, unreadable ciphertext, or missing critical resources.

### Remediation Steps
1. List prior state versions in S3:
   ```bash
   aws s3api list-object-versions \
     --bucket halcyon-opentofu-states-us-east-1 \
     --prefix workloads/prod/platform.tfstate
   ```
2. Download the known good version:
   ```bash
   aws s3api get-object \
     --bucket halcyon-opentofu-states-us-east-1 \
     --key workloads/prod/platform.tfstate \
     --version-id <VERSION_ID> \
     recovered_state.tfstate
   ```
3. Push the recovered state:
   ```bash
   tofu state push recovered_state.tfstate
   ```
4. Perform non-destructive cloud refresh:
   ```bash
   tofu apply -refresh-only
   ```
