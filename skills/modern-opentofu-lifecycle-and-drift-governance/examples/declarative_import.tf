# Declarative Resource Adoption Blueprint
# Adopts existing AWS resources into OpenTofu state declaratively

import {
  to = aws_s3_bucket.central_audit_logs
  id = "corp-central-audit-logs-production"
}

# Run 'tofu plan -generate-config-out=generated_bucket.tf' to generate the HCL block below:
resource "aws_s3_bucket" "central_audit_logs" {
  bucket = "corp-central-audit-logs-production"

  lifecycle {
    prevent_destroy = true
  }
}
