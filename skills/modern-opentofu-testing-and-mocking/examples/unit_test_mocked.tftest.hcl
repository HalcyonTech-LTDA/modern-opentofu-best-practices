# Modern OpenTofu 1.8+ Unit Test Suite with Mock Provider
# Executes without any AWS credentials, cloud connections, or billing costs.

mock_provider "aws" {
  mock_resource "aws_vpc" {
    defaults = {
      id  = "vpc-mock12345678"
      arn = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-mock12345678"
    }
  }

  mock_resource "aws_subnet" {
    defaults = {
      id = "subnet-mock12345678"
    }
  }
}

variables {
  vpc_name           = "test-mock-vpc"
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

run "verify_vpc_mocked_outputs" {
  command = plan

  assert {
    condition     = output.vpc_id == "vpc-mock12345678"
    error_message = "Output VPC ID does not match expected mocked value."
  }

  assert {
    condition     = length(output.private_subnet_ids) == 2
    error_message = "Expected exactly 2 private subnets for two AZs."
  }
}
