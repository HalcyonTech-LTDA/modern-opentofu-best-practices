# Remote Backends & Distributed State Locking

Remote state backends provide centralized storage, high durability, team collaboration, and state locking to prevent concurrent destructive runs.

---

## 1. Amazon S3 + DynamoDB Locking

The standard cloud-agnostic architecture for AWS deployments:

```hcl
terraform {
  backend "s3" {
    bucket         = "halcyon-opentofu-states-us-east-1"
    key            = "workloads/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "halcyon-opentofu-locks"
    encrypt        = true # Server-side S3 encryption (complements client-side OpenTofu encryption)
  }
}
```

### Invariants for S3 State Storage:
1. **Enable S3 Versioning**: Guarantees recovery from accidental state corruption or erroneous state surgery.
2. **Block Public Access**: Apply `aws_s3_bucket_public_access_block` with all four block settings enabled.
3. **KMS Bucket Encryption**: Enforce `aws_kms` default encryption on the S3 bucket.
4. **Locking Table**: DynamoDB table must have `LockID` (String) as primary partition key.

---

## 2. Azure Blob Storage with Native Blob Leasing

Azure Blob Storage provides native distributed leasing locks without requiring an auxiliary database:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-platform-governance"
    storage_account_name = "stplatformopentofustate"
    container_name       = "tfstates"
    key                  = "networking.prod.tfstate"
    use_oidc             = true # Passwordless Azure OIDC authentication
  }
}
```

---

## 3. Google Cloud Storage (GCS)

```hcl
terraform {
  backend "gcs" {
    bucket = "halcyon-opentofu-state-prod"
    prefix = "compute/gke-cluster"
  }
}
```

---

## 4. State Lock Contention & Safety Procedures

When concurrent runs or interrupted CI jobs hold a state lock:
- Error message: `Error: Error acquiring the state lock`
- Always verify no active pipeline runner is executing before releasing a lock:
  ```bash
  # Inspect the lock ID from error output, then release
  tofu force-unlock <LOCK-ID>
  ```
- In CI pipelines, always specify lock acquisition timeouts:
  ```bash
  tofu plan -lock-timeout=5m
  tofu apply -lock-timeout=10m
  ```
