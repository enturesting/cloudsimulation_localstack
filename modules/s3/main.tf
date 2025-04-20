resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Environment = "local"
    ManagedBy   = "Terraform"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
