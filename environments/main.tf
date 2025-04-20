# main.tf (shared entrypoint)

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.28.0"
    }
  }
}

provider "aws" {
  alias                       = "localstack"
  region                      = "us-east-1"
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    ec2      = "http://localhost:4566"
    iam      = "http://localhost:4566"
    kms      = "http://localhost:4566"
    sts      = "http://localhost:4566"
  }
}

module "s3_bucket" {
  source      = "../modules/s3"
  bucket_name = var.bucket_name

  providers = {
    aws = aws.localstack
  }
}

module "dynamodb_table" {
  source         = "../modules/dynamodb"
  table_name     = var.table_name
  hash_key       = var.hash_key
  attribute_type = var.attribute_type
  tags = {
    Environment = var.environment_name
    Owner       = var.owner
  }
  enable_sse = var.enable_sse

  providers = {
    aws = aws.localstack
  }
}

module "ec2_instance" {
  count         = var.enable_ec2 ? 1 : 0
  source        = "../modules/ec2"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  user_data     = var.user_data

  providers = {
    aws = aws.localstack
  }
}

module "vpc" {
  count  = var.enable_vpc ? 1 : 0
  source = "../modules/vpc"
  tags   = var.common_tags
  # name = "optional-custom-name"  # Optional now
  providers = {
    aws = aws.localstack
  }
}

module "kms" {
  count            = var.enable_kms ? 1 : 0
  source           = "../modules/kms"
  environment_name = var.environment_name
  tags             = var.common_tags
  providers = {
    aws = aws.localstack
  }
}

module "iam" {
  count            = var.enable_iam ? 1 : 0
  source           = "../modules/iam"
  environment_name = var.environment_name
  tags             = var.common_tags
  providers = {
    aws = aws.localstack
  }
}
