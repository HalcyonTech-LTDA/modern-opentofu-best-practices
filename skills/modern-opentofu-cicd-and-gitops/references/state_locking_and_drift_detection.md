# State Locking & Drift Detection Governance

Managing concurrency, handling lock deadlocks, and continuously detecting infrastructure drift are essential operational disciplines.

---

## 1. Concurrency Control in GitOps

When multiple team members or CI jobs trigger simultaneously:
- Without concurrency limits, Job B may abort because Job A is holding the DynamoDB/Azure blob lock.
- Configure concurrency queues in your CI engine:

```yaml
# In GitHub Actions
concurrency:
  group: opentofu-env-${{ inputs.environment || 'main' }}
  cancel-in-progress: false # Never kill a running apply!
```

Setting `cancel-in-progress: false` is vital: cancelling a running `tofu apply` can cause orphaned cloud resources or leave state partially mutated.

---

## 2. Unlocking Stale State Safely

If a CI runner machine terminates abruptly (OOM killed, spot instance reclaimed) during an apply, the state lock may remain held:

1. Identify the Lock ID from error logs:
   ```text
   Lock Info:
     ID:        3b469a7c-4712-4cf4-92da-1901abcf43ef
     Path:      halcyon-opentofu-states-us-east-1/workloads/prod/platform.tfstate
     Operation: OperationTypeApply
     Who:       runner@github-runner-4
     Created:   2026-11-04 10:14:00 UTC
   ```
2. Confirm the runner is completely dead.
3. Release the lock:
   ```bash
   tofu force-unlock -force 3b469a7c-4712-4cf4-92da-1901abcf43ef
   ```
4. Run `tofu refresh` or `tofu plan` to verify the state matches live cloud resources.

---

## 3. Scheduled Drift Detection

Configure a nightly or hourly scheduled pipeline:

```bash
tofu plan -detailed-exitcode -no-color -lock=false > drift_output.txt
EXIT_CODE=$?

if [ $EXIT_CODE -eq 2 ]; then
  echo "CRITICAL: Cloud drift detected!"
  # Dispatch alert to Slack / PagerDuty with drift_output.txt summary
  exit 2
fi
```
- `-detailed-exitcode` returns `2` when changes or drift exist.
- `-lock=false` prevents the drift check from blocking regular pipeline runs.
