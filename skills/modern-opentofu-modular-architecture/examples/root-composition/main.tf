module "vpc" {
  source = "../vpc-child-module"

  vpc_name           = "${var.project_name}-${var.environment}-vpc"
  cidr_block         = "10.100.0.0/16"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]

  tags = {
    Tier = "Foundation"
  }
}
