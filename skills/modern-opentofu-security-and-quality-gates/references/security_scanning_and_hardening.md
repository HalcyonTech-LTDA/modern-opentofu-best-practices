# Security Hardening & Vulnerability Scanning for OpenTofu

Static Application Security Testing (SAST) for Infrastructure as Code prevents misconfigurations before they reach cloud runtime environments.

---

## 1. Scanner Matrix: Trivy & Checkov

| Tool | Focus | Command |
| :--- | :--- | :--- |
| **Trivy** | Fast SAST, CVE detection, CIS benchmarks | `trivy config --severity HIGH,CRITICAL .` |
| **Checkov** | 1000+ policy-as-code checks, NIST/PCI-DSS/HIPAA | `checkov -d . --framework terraform --compact` |
| **tfsec** | Integrated into Trivy | Legacy, modern workflows standardize on Trivy |

---

## 2. Mandatory Security Baselines

Every OpenTofu module must enforce the following security invariants:

1. **Storage Encryption**:
   - S3 buckets must enforce KMS CMK encryption (`aws_s3_bucket_server_side_encryption_configuration`).
   - EBS volumes must set `encrypted = true`.
   - RDS instances must set `storage_encrypted = true`.

2. **Network Isolation**:
   - Databases must never have public accessibility enabled (`publicly_accessible = false`).
   - S3 buckets must enforce `aws_s3_bucket_public_access_block`.
   - Security groups must ban `0.0.0.0/0` ingress on management ports (SSH port 22, RDP port 3389, DB port 5432).

3. **Logging & Auditability**:
   - S3 access logging or AWS CloudTrail data event logging must be enabled for sensitive buckets.
   - Load balancers must send access logs to centralized S3/CloudWatch destinations.
   - VPC Flow Logs must be enabled on all non-sandbox subnets.

4. **Zero Plaintext Secrets**:
   - Use dynamic data sources (`aws_secretsmanager_secret_version`) or IAM role federation instead of passing passwords in code.
