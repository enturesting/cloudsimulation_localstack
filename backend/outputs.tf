output "state_bucket_name" {
  description = "Name of the S3 bucket for terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket for terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "lock_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_lock.arn
}

output "backend_config" {
  description = "Backend configuration for use in other terraform configs"
  sensitive   = true
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_lock.name
    encrypt        = true
    endpoint       = var.localstack_endpoint
    
    # LocalStack specific settings
    access_key                  = var.access_key
    secret_key                  = var.secret_key
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    s3_use_path_style          = true
  }
}