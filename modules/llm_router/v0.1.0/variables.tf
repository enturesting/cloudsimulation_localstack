variable "environment" {
  description = "Environment name (e.g., develop, nonprod, prod)"
  type        = string
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

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL (for local development)"
  type        = string
  default     = null
} 