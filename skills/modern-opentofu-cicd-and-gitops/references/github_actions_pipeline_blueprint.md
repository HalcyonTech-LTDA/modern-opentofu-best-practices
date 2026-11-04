# GitHub Actions Pipeline Architecture for OpenTofu

A battle-tested CI/CD workflow architecture enforces multi-stage quality gates, plan immutability, and controlled production applies.

---

## Architecture Flow

```text
PR Created / Updated
  │
  ├── 1. Pre-Flight Quality Gate (Parallel)
  │    ├── tofu fmt -check
  │    ├── tofu validate
  │    ├── tflint
  │    └── trivy config scan
  │
  ├── 2. Unit Testing Gate
  │    └── tofu test (using mock_provider)
  │
  ├── 3. Speculative Plan Gate (OIDC)
  │    ├── tofu plan -out=tfplan
  │    ├── Infracost breakdown
  │    └── Post PR Comment (Plan Summary + FinOps)
  │
PR Approved & Merged to main
  │
  └── 4. Production Apply Gate
       ├── Download Plan Artifact
       ├── Manual Environment Approval (GitHub Environments)
       └── tofu apply tfplan
```

---

## Best Practices in Pipelines

1. **Use Official OpenTofu Setup Action**:
   ```yaml
   - uses: opentofu/setup-opentofu@v1
     with:
       tofu_version: 1.8.2
   ```

2. **Always Cache Provider Plugins**:
   - Save runner bandwidth and speed up runs by pointing `plugin_cache_dir` to `~/.tofu.d/plugin-cache` and caching via `actions/cache`.

3. **Lock Timeout Invariants**:
   - Always append `-lock-timeout=5m` to prevent jobs from hanging indefinitely if another process momentarily holds the lock.

4. **Upload Plan as an Artifact**:
   - Speculative plan files (`tfplan`) should be uploaded as GitHub workflow artifacts (encrypted by OpenTofu native state encryption) and downloaded in the apply job to ensure absolute execution fidelity.
