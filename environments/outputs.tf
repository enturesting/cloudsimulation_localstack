# S3 Outputs
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.s3_bucket.bucket_name
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

# DynamoDB Outputs
output "table_name" {
  description = "The name of the DynamoDB table"
  value       = module.dynamodb_table.table_name
}

output "table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = module.dynamodb_table.table_arn
}

output "table_stream_arn" {
  description = "The stream ARN of the DynamoDB table (if applicable)"
  value       = module.dynamodb_table.table_stream_arn
  sensitive   = false
}

# EC2 Outputs (conditionally shown)
output "instance_id" {
  description = "EC2 instance ID (only if enabled)"
  value       = var.enable_ec2 ? module.ec2_instance[0].instance_id : null
}

output "ec2_public_ip" {
  description = "Public IP of EC2 (dev only)"
  value       = var.enable_ec2 && var.environment_name == "dev" ? module.ec2_instance[0].public_ip : null
}

output "instance_private_ip" {
  description = "Private IP of EC2 instance (if enabled)"
  value       = var.enable_ec2 ? module.ec2_instance[0].private_ip : null
}

# Optional modules
output "kms_key_id" {
  value = var.enable_kms ? module.kms[0].key_id : null
}

output "vpc_id" {
  value = var.enable_vpc ? module.vpc[0].vpc_id : null
}

output "iam_role_name" {
  description = "IAM Role name (if IAM is enabled)"
  value       = var.enable_iam ? module.iam[0].role_name : null
}

# Summary Output
output "summary" {
  description = "High-level summary of deployed resources"
  value = {
    environment = var.environment_name
    ec2         = var.enable_ec2 ? "Provisioned" : "Skipped"
    vpc         = var.enable_vpc ? "Provisioned" : "Skipped"
    kms         = var.enable_kms ? "Provisioned" : "Skipped"
    iam         = var.enable_iam ? "Provisioned" : "Skipped"
    bucket      = module.s3_bucket.bucket_name
    table       = module.dynamodb_table.table_name
  }
}

# Debug info output (enabled via var.output_debug_info)
output "debug_info" {
  description = "Detailed debug output (only shown when enabled)"
  value = var.output_debug_info ? {
    environment    = var.environment_name
    owner          = var.owner
    s3_bucket      = module.s3_bucket.bucket_name
    dynamodb_table = module.dynamodb_table.table_name
    ec2_instance   = var.enable_ec2 ? module.ec2_instance[0].instance_id : "disabled"
    kms_enabled    = var.enable_kms
    vpc_enabled    = var.enable_vpc
    iam_enabled    = var.enable_iam
  } : null
}

output "ami_id" {
  description = "The AMI ID registered for this environment"
  value       = var.ami_id
}

output "api_gateway_url" {
  value = var.enable_api_gateway ? module.api_gateway[0].invoke_url : ""
}

output "lambda_function_name" {
  value = var.enable_lambda ? module.lambda[0].function_name : ""
}