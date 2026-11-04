terraform {
  required_version = ">= 1.8.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "opentofu/aws"
      version = "~> 5.50"
    }
  }
}
