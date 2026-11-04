variable "vpc_name" {
  type        = string
  description = "Logical name for the VPC deployment."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.vpc_name))
    error_message = "VPC name must contain only lowercase alphanumeric characters and hyphens."
  }
}

variable "cidr_block" {
  type        = string
  description = "IPv4 CIDR block for the VPC."
  default     = "10.0.0.0/16"
  nullable    = false

  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "The cidr_block must be a valid IPv4 CIDR string."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for multi-AZ deployment."
  nullable    = false

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required for redundancy."
  }
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames inside the VPC."
  default     = true
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "Additional resource tags."
  default     = {}
}
