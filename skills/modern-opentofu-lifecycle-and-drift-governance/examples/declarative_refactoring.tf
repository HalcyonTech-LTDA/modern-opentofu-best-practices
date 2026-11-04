# Declarative Refactoring Blueprint
# Demonstrates moved blocks and OpenTofu 1.7+ removed blocks

# 1. Zero-downtime resource rename via moved block
moved {
  from = aws_security_group.ingress_legacy
  to   = aws_security_group.ingress_v2
}

# 2. Refactoring a resource into a child module without recreation
moved {
  from = aws_s3_bucket.app_assets
  to   = module.storage.aws_s3_bucket.this
}

# 3. Safely unmanaging a resource in OpenTofu 1.7+ without destroying cloud infrastructure
removed {
  from = aws_iam_role.legacy_ci_role

  lifecycle {
    destroy = false # OpenTofu drops it from state; IAM role remains active in AWS
  }
}
