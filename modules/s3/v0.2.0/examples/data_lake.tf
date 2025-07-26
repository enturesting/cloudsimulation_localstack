# Example: Data Lake S3 Bucket with Lifecycle Management
# This example shows how to use the S3 module for a data lake with tiered storage

module "data_lake_raw" {
  source = "../"
  
  environment_name = "prod"
  bucket_name     = "company-data-lake-raw"
  
  # Enable versioning for data protection
  enable_versioning = true
  
  # Enable server-side encryption
  enable_encryption = true
  encryption_key_id = var.kms_key_id
  
  # Lifecycle configuration for cost optimization
  lifecycle_rules = [
    {
      id     = "data-lifecycle"
      status = "Enabled"
      
      # Transition to IA after 30 days
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 365
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      
      # Delete incomplete multipart uploads after 7 days
      abort_incomplete_multipart_upload_days = 7
    }
  ]
  
  # Bucket notifications for data processing
  enable_notifications = true
  notification_config = {
    lambda_configurations = [
      {
        lambda_function_arn = var.data_processor_lambda_arn
        events             = ["s3:ObjectCreated:*"]
        filter_prefix      = "incoming/"
        filter_suffix      = ".json"
      }
    ]
  }
  
  tags = {
    Environment = "production"
    Purpose     = "data-lake"
    Team        = "data-engineering"
    CostCenter  = "analytics"
  }
}

module "data_lake_processed" {
  source = "../"
  
  environment_name = "prod"
  bucket_name     = "company-data-lake-processed"
  
  # Enable versioning
  enable_versioning = true
  
  # Different lifecycle for processed data
  lifecycle_rules = [
    {
      id     = "processed-data-lifecycle"
      status = "Enabled"
      
      transition = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 180
          storage_class = "GLACIER"
        }
      ]
    }
  ]
  
  tags = {
    Environment = "production"
    Purpose     = "data-lake-processed"
    Team        = "data-engineering"
    CostCenter  = "analytics"
  }
}

# Cross-region replication bucket
module "data_lake_backup" {
  source = "../"
  
  environment_name = "prod"
  bucket_name     = "company-data-lake-backup"
  region          = "us-west-2"  # Different region for disaster recovery
  
  enable_versioning = true
  
  tags = {
    Environment = "production"
    Purpose     = "data-lake-backup"
    Team        = "data-engineering"
    CostCenter  = "analytics"
  }
}

# Variables
variable "kms_key_id" {
  description = "KMS key ID for bucket encryption"
  type        = string
}

variable "data_processor_lambda_arn" {
  description = "ARN of the Lambda function for data processing"
  type        = string
}

# Outputs
output "raw_bucket_name" {
  description = "Name of the raw data bucket"
  value       = module.data_lake_raw.bucket_name
}

output "processed_bucket_name" {
  description = "Name of the processed data bucket"
  value       = module.data_lake_processed.bucket_name
}

output "backup_bucket_name" {
  description = "Name of the backup bucket"
  value       = module.data_lake_backup.bucket_name
}