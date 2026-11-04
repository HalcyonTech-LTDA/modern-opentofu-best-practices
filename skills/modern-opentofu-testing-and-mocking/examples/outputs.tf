output "vpc_id" {
  value       = aws_vpc.this.id
  description = "Identifier of the provisioned VPC."
}

output "vpc_arn" {
  value       = aws_vpc.this.arn
  description = "Amazon Resource Name (ARN) of the VPC."
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "List of public subnet IDs."
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "List of private subnet IDs."
}
