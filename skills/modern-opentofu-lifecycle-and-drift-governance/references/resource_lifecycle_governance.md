# Resource Lifecycle Governance in OpenTofu

Controlling resource lifecycles ensures high availability during replacements, prevents catastrophic data loss, and isolates external cloud mutations.

---

## 1. `prevent_destroy` for Stateful Workloads

Apply to databases, S3 storage buckets, KMS keys, Elastic IPs, and foundational VPCs:

```hcl
resource "aws_db_instance" "production_postgres" {
  identifier     = "prod-core-db"
  instance_class = "db.r6g.xlarge"
  engine         = "postgres"
  # ...

  lifecycle {
    prevent_destroy = true
  }
}
```

If an engineer or pipeline accidentally removes this resource block or alters a parameter forcing replacement (e.g. changing DB engine family), OpenTofu halts planning immediately with an error:
`Error: Instance cannot be destroyed`

---

## 2. `create_before_destroy` for Zero-Downtime Updates

Standard replacement terminates old infrastructure before creating new infrastructure, causing minutes of service downtime. `create_before_destroy` reverses this sequence:

```hcl
resource "aws_launch_template" "web" {
  name_prefix   = "web-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  lifecycle {
    create_before_destroy = true
  }
}
```

---

## 3. Surgical `ignore_changes`

External systems (such as autoscalers, Kubernetes controllers, or third-party backup tools) frequently mutate specific resource attributes out of band. Use surgical attribute lists:

```hcl
resource "aws_autoscaling_group" "workers" {
  name                = "worker-asg"
  desired_capacity    = 3
  max_size            = 10
  min_size            = 2
  # ...

  lifecycle {
    ignore_changes = [
      desired_capacity, # Mutated dynamically by AWS Auto Scaling policies
      target_group_arns
    ]
  }
}
```
Prohibit `ignore_changes = all`. Blanket ignores blind OpenTofu to legitimate drift and security misconfigurations.
