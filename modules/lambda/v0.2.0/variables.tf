variable "filename" {
  description = "Path to the function's deployment package within the local filesystem"
  type        = string
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "role_arn" {
  description = "IAM role ARN attached to the Lambda Function"
  type        = string
}

variable "handler" {
  description = "Function entrypoint in your code"
  type        = string
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
}

variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the Lambda function"
  type        = map(string)
  default     = {}
}

variable "allow_api_gateway" {
  description = "Whether to allow API Gateway to invoke this Lambda function"
  type        = bool
  default     = true
}

variable "api_gateway_execution_arn" {
  description = "ARN of the API Gateway execution role"
  type        = string
  default     = ""
}

variable "dynamodb_table" {
  description = "Name of the DynamoDB table to interact with"
  type        = string
} 