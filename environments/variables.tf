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

variable "key_name" {
  description = "EC2 key pair name (unused in LocalStack, but required by module)"
  type        = string
  default     = null
}

variable "localstack_api_key" {
  description = "LocalStack Pro API key"
  type        = string
  default     = ""
}

variable "aws_access_key" {
  description = "Optional AWS access key for mock purposes"
  type        = string
  default     = ""
}

variable "localstack_port" {
  description = "Port used by LocalStack for the given environment"
  type        = number
  default     = 4566
}

variable "enable_api_gateway" {
  description = "Whether to enable API Gateway module"
  type        = bool
  default     = false
}

variable "enable_lambda" {
  description = "Whether to enable Lambda module"
  type        = bool
  default     = false
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "api-handler"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "api-gateway"
}

variable "api_gateway_stage_name" {
  description = "Stage name for the API Gateway"
  type        = string
  default     = "dev"
}

variable "api_gateway_path" {
  description = "Base path for the API Gateway"
  type        = string
  default     = "api"
}

variable "api_gateway_methods" {
  description = "HTTP methods to enable on the API Gateway"
  type        = list(string)
  default     = ["GET", "POST"]
}

variable "lambda_module_version" { default = "v0.1.0" }
variable "api_gateway_module_version" { default = "v0.1.0" }
variable "iam_module_version" { default = "v0.1.0" }
variable "dynamodb_module_version" { default = "v0.1.0" }
variable "vpc_module_version" { default = "v0.1.0" }
variable "s3_module_version" { default = "v0.1.0" }
variable "kms_module_version" { default = "v0.1.0" }
variable "ec2_module_version" { default = "v0.1.0" }