variable "vpc_name" {
  description = "Name tag for the VPC; also used as a prefix for all child resources."
  type        = string
  default     = "Terraform-ci-cd-vpc"
}

variable "vpc_cidr" {
  description = "Primary IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_region" {
  description = "AWS region — used to build the S3 VPC endpoint service name."
  type        = string
  default     = "us-east-1"
}

# ------------------------------------------------------------------------------
# Public subnets
# Mirrors the console:
#   ci-cd-subnet-public1-us-east-1a  →  us-east-1a
#   ci-cd-subnet-public2-us-east-1b  →  us-east-1b
# ------------------------------------------------------------------------------
variable "public_subnets" {
  description = "List of public subnet definitions. Each object needs name, cidr, and az."
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = [
    {
      name = "ci-cd-subnet-public1-us-east-1a"
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    },
    {
      name = "ci-cd-subnet-public2-us-east-1b"
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  ]
}

# ------------------------------------------------------------------------------
# Private subnets
# Mirrors the console:
#   ci-cd-subnet-private1-us-east-1a  →  us-east-1a
#   ci-cd-subnet-private2-us-east-1b  →  us-east-1b
# ------------------------------------------------------------------------------
variable "private_subnets" {
  description = "List of private subnet definitions. Each object needs name, cidr, and az."
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = [
    {
      name = "ci-cd-subnet-private1-us-east-1a"
      cidr = "10.0.3.0/24"
      az   = "us-east-1a"
    },
    {
      name = "ci-cd-subnet-private2-us-east-1b"
      cidr = "10.0.4.0/24"
      az   = "us-east-1b"
    }
  ]
}

variable "tags" {
  description = "Additional tags merged onto every resource in this module."
  type        = map(string)
  default = {
    Project   = "ci-cd"
    ManagedBy = "terraform"
  }
}
