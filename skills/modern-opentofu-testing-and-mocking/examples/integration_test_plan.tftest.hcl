# Plan-based Assertion Test Suite
# Validates resource parameters, calculated CIDRs, and tag propagation.

mock_provider "aws" {}

variables {
  vpc_name           = "test-integration-vpc"
  cidr_block         = "172.16.0.0/16"
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  tags = {
    Environment = "test"
    CostCenter  = "CC-1092"
  }
}

run "verify_plan_attributes" {
  command = plan

  assert {
    condition     = aws_vpc.this.cidr_block == "172.16.0.0/16"
    error_message = "VPC CIDR block was not configured properly in plan."
  }

  assert {
    condition     = aws_vpc.this.tags["CostCenter"] == "CC-1092"
    error_message = "CostCenter tag missing on VPC resource."
  }

  assert {
    condition     = length(aws_subnet.public) == 3
    error_message = "Expected 3 public subnets to be created."
  }
}
