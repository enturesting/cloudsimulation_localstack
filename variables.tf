# variables.tf

variable "access_key" {
  description = "AWS access key"
  type        = string
}

variable "secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "hash_key" {
  description = "Primary hash key for DynamoDB table"
  type        = string
}

variable "attribute_type" {
  description = "Attribute type for DynamoDB table hash key"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "environment_name" {
  description = "Environment name (e.g., dev, nonprod)"
  type        = string
}

variable "owner" {
  description = "Owner of the environment"
  type        = string
}

variable "enable_kms" {
  description = "Whether to enable KMS module"
  type        = bool
  default     = false
}

variable "enable_ec2" {
  description = "Whether to enable EC2 instance module"
  type        = bool
  default     = false
}

variable "enable_sse" {
  description = "Enable server-side encryption on DynamoDB"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "User data script for EC2 instance"
  type        = string
  default     = ""
}

variable "enable_vpc" {
  type        = bool
  default     = false
  description = "Enable VPC provisioning"
}

variable "enable_iam" {
  type        = bool
  default     = true
  description = "Whether to enable IAM module"
}

variable "output_debug_info" {
  description = "Whether to show detailed debug outputs"
  type        = bool
  default     = false
}

variable "ami_id" {
  description = "The mock AMI ID registered for EC2"
  type        = string
}

variable "account_id" {
  type        = string
  description = "Mock AWS account ID for use in simulated resources"
}

# variable "name" {
#   type        = string
#   description = "Name or identifier used for naming resources (e.g. VPC, tags)"
# }

# variable "subnet_id" {
#   description = "The subnet ID for the EC2 instance"
#   type        = string
# }

# variable "security_groups" {
#   description = "List of security group IDs to attach to the instance"
#   type        = list(string)
# }
