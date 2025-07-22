variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
  description = "AWS access key (LocalStack)"
  type        = string
  default     = "test"
  sensitive   = true
}

variable "secret_key" {
  description = "AWS secret key (LocalStack)"
  type        = string
  default     = "test"
  sensitive   = true
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  type        = string
  default     = "http://localhost:4566"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for storing terraform state"
  type        = string
  default     = "terraform-state-localstack"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-locks"
}