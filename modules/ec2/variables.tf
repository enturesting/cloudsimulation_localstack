variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "ami" {
  type        = string
  description = "AMI ID to use"
}

variable "user_data" {
  description = "User data script for EC2 instance"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
  default     = null
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to the instance"
  type        = map(string)
  default     = {}
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instance"
}