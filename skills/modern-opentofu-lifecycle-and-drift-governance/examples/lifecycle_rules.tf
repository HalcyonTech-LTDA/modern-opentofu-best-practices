# Resource Lifecycle Governance Configurations
# Demonstrates prevent_destroy, create_before_destroy, and surgical ignore_changes

# 1. Stateful Database with Deletion Protection
resource "aws_db_instance" "primary_postgres" {
  identifier          = "corp-platform-postgres-prod"
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.r6g.xlarge"
  allocated_storage   = 100
  storage_encrypted   = true
  skip_final_snapshot = false

  lifecycle {
    prevent_destroy = true
  }
}

# 2. Zero-Downtime Compute Launch Template
resource "aws_launch_template" "api_server" {
  name_prefix   = "api-server-template-"
  image_id      = "ami-0123456789abcdef0"
  instance_type = "c6i.large"

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Surgical ignore_changes for Externally Mutated Autoscaling
resource "aws_autoscaling_group" "api_servers" {
  name_prefix         = "api-asg-"
  min_size            = 2
  max_size            = 12
  desired_capacity    = 4
  vpc_zone_identifier = ["subnet-11111111", "subnet-22222222"]

  lifecycle {
    ignore_changes = [
      desired_capacity,
      load_balancers,
      target_group_arns
    ]
  }
}
