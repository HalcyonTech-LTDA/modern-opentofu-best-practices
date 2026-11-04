# Amazon S3 Backend Configuration with Distributed DynamoDB Locking
# Supports OpenTofu 1.8+ Early Variable Evaluation

terraform {
  backend "s3" {
    bucket         = "halcyon-opentofu-states-us-east-1"
    key            = "workloads/prod/platform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "halcyon-opentofu-locks"
    encrypt        = true
  }
}
