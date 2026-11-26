variable "env" {
  description = "Environment name (dev, staging, or prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for deployed resources."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the environment VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "subnets" {
  description = "Map of subnets keyed by name with CIDR and AZ suffix."
  type = map(object({
    cidr_block = string
    az_suffix  = string
  }))

  validation {
    condition     = alltrue([for s in var.subnets : can(cidrnetmask(s.cidr_block))])
    error_message = "Every subnet entry must have a valid IPv4 cidr_block."
  }
}

variable "instance_type" {
  description = "EC2 instance type for this environment."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small"], var.instance_type)
    error_message = "instance_type must be t3.micro or t3.small."
  }
}

variable "ssm_parameter_name" {
  description = "Existing SSM Parameter Store path read out-of-band via data source."
  type        = string
}

variable "alarm_cpu_threshold" {
  description = "CPUUtilization threshold percentage for the CloudWatch alarm."
  type        = number
  default     = 80
}

variable "tags" {
  description = "Environment-specific tags."
  type        = map(string)
  default     = {}
}
