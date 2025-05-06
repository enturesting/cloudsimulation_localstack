variable "environment" {
  description = "The environment name (e.g., develop, nonprod)"
  type        = string
  validation {
    condition     = contains(["develop", "nonprod"], var.environment)
    error_message = "environment must be either 'develop' or 'nonprod'"
  }
}

variable "region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket" {
  description = "The S3 bucket to store Terraform state"
  type        = string
}

variable "localstack_ports" {
  description = "LocalStack ports configuration"
  type = object({
    api = number
    ui  = number
  })
  default = {
    api = 4566
    ui  = 31566
  }
}

variable "access_key" {
  description = "LocalStack access key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "LocalStack secret key"
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "LocalStack account ID"
  type        = string
}

variable "localstack_api_key" {
  description = "LocalStack API key"
  type        = string
  default     = null
}

variable "enable_vpc" {
  description = "Enable VPC configuration"
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Prefix to be used for all resource names"
  type        = string
  default     = null
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function zip file"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
