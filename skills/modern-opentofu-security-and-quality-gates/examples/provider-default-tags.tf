provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "OpenTofu"
      Repository  = "https://github.com/HalcyonTech-LTDA/infrastructure"
      CostCenter  = "INFRA-PROD-01"
    }
  }
}
