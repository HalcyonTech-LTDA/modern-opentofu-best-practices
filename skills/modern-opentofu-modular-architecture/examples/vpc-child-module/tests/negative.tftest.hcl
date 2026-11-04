# Negative Validation Test Suite for VPC Child Module
# Asserts that domain constraints reject illegal inputs

mock_provider "aws" {}

run "expect_failure_invalid_cidr" {
  command = plan

  variables {
    vpc_name           = "invalid-vpc"
    cidr_block         = "999.999.999.999/99"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  expect_failures = [
    var.cidr_block
  ]
}

run "expect_failure_single_az" {
  command = plan

  variables {
    vpc_name           = "single-az-vpc"
    cidr_block         = "10.0.0.0/16"
    availability_zones = ["us-east-1a"]
  }

  expect_failures = [
    var.availability_zones
  ]
}
