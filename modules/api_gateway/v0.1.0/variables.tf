variable "name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
}

variable "path" {
  description = "Base path for the API Gateway"
  type        = string
  default     = "api"
}

variable "methods" {
  description = "List of HTTP methods to enable"
  type        = list(string)
  default     = ["GET", "POST"]
}

variable "lambda_invoke_arn" {
  description = "ARN of the Lambda function to invoke"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the API Gateway"
  type        = map(string)
  default     = {}
} 