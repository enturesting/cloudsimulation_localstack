variable "name" {
  description = "Name tag for the VPC and related resources"
  type        = string
  default     = "default-vpc"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to use"
  type        = number
  default     = 2
}

variable "create_public_subnets" {
  description = "Whether to create public subnets"
  type        = bool
  default     = true
}

variable "create_private_subnets" {
  description = "Whether to create private subnets"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnets"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}