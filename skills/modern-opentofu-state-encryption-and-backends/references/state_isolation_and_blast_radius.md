# State Isolation & Blast-Radius Management

A critical failure mode in infrastructure as code is maintaining a "monolithic state" where networking, databases, Kubernetes clusters, and microservice definitions are stored in a single state file.

---

## 1. The Monolithic State Anti-Pattern

Storing all cloud infrastructure in one state file introduces acute failure modes:
1. **Catastrophic Blast Radius**: A mistake in a microservice deployment can corrupt, lock, or destroy core network routing or primary databases.
2. **Performance Degradation**: Refreshing hundreds of cloud resources during `tofu plan` takes 15–45 minutes, paralyzing engineering throughput.
3. **High Lock Contention**: Independent engineering teams block each other whenever someone triggers a pipeline.
4. **Coarse-Grained Security**: All developers and CI runners require broad admin permissions to modify anything in the monolithic state.

---

## 2. Layered Architecture (Blast-Radius Segmentation)

Segment state files horizontally by environment and vertically by architectural layer:

```text
infrastructure/
├── environments/
│   ├── dev/
│   │   ├── 01-networking/     # VPC, Subnets, Gateways, Route Tables, Transit Gateway
│   │   ├── 02-security/       # Shared IAM roles, KMS keys, WAF policies
│   │   ├── 03-persistence/    # RDS instances, DynamoDB tables, Elasticache
│   │   └── 04-workloads/      # ECS services, EKS apps, Lambda functions
│   └── prod/
│       ├── 01-networking/
│       ├── 02-security/
│       ├── 03-persistence/
│       └── 04-workloads/
```

---

## 3. Decoupling Inter-State Dependencies

When Layer 04 (Workloads) needs the VPC ID or Subnet IDs from Layer 01 (Networking), avoid broad `tofu_remote_state` data sources if possible.

### Recommended Pattern: Parameter / Secret Store Decoupling

In Layer 01 (Networking):
```hcl
resource "aws_ssm_parameter" "vpc_id" {
  name        = "/platform/${var.environment}/network/vpc_id"
  type        = "String"
  value       = aws_vpc.this.id
  description = "VPC ID for workload consumption"
}
```

In Layer 04 (Workloads):
```hcl
data "aws_ssm_parameter" "vpc_id" {
  name = "/platform/${var.environment}/network/vpc_id"
}

# Use directly: data.aws_ssm_parameter.vpc_id.value
```

### Advantages:
1. No cross-state read permissions needed.
2. Consumers do not parse huge state JSON blobs.
3. Loosely coupled architecture with clear contractual endpoints.
