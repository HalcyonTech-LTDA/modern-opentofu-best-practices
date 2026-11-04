# Provider Mocking & Overrides in OpenTofu 1.8+

One of OpenTofu's most powerful capabilities is **native provider mocking**. Before this feature, testing infrastructure code either required live cloud credentials or complex Go-based harnesses.

---

## 1. Declaring Mock Providers

In your `*.tftest.hcl` file, define a `mock_provider` block corresponding to the cloud provider:

```hcl
# tests/mock_test.tftest.hcl

mock_provider "aws" {
  # Optionally mock specific data sources or resources with static or calculated returns
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
  }

  mock_resource "aws_vpc" {
    defaults = {
      id  = "vpc-mocked12345"
      arn = "arn:aws:ec2:us-east-1:123456789012:vpc/vpc-mocked12345"
    }
  }
}

run "unit_test_without_credentials" {
  command = plan

  assert {
    condition     = output.vpc_id == "vpc-mocked12345"
    error_message = "Output VPC ID did not match the mocked provider value."
  }
}
```

---

## 2. Resource & Data Source Overrides

You can override specific resources or data sources inside individual `run` blocks:

```hcl
run "override_specific_resource" {
  command = plan

  override_resource {
    target = aws_subnet.public[0]
    values = {
      id = "subnet-mockedpublic0"
    }
  }

  assert {
    condition     = contains(output.public_subnet_ids, "subnet-mockedpublic0")
    error_message = "Expected mocked subnet ID in public subnet list."
  }
}
```

---

## 3. Benefits in CI/CD Pipelines

1. **Zero Cloud Credentials Required**: PR builds from external contributors or unprivileged branches run completely in a sandbox.
2. **Deterministic Speed**: Mocked tests execute in under 2 seconds without HTTP latency or rate limits.
3. **Zero Cost**: Eliminates ephemeral AWS/Azure billings incurred by unit tests.
4. **Resilience to Cloud Outages**: Tests pass reliably regardless of cloud provider API downtime.
