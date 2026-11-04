variable "aws_region" {
  type        = string
  description = "Target AWS region."
  default     = "us-east-1"
  nullable    = false
}

variable "environment" {
  type        = string
  description = "Environment tier name."
  default     = "staging"
  nullable    = false

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  type        = string
  description = "Project name identifier."
  default     = "core-platform"
  nullable    = false
}
