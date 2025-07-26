# main.tf (LLM Router environment)

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.28.0"
    }
  }
  backend "local" {}
}

# Default provider
provider "aws" {
  region                      = var.region
  alias                       = "localstack"
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3         = "http://localhost:${var.localstack_ports.api}"
    dynamodb   = "http://localhost:${var.localstack_ports.api}"
    ec2        = "http://localhost:${var.localstack_ports.api}"
    iam        = "http://localhost:${var.localstack_ports.api}"
    kms        = "http://localhost:${var.localstack_ports.api}"
    sts        = "http://localhost:${var.localstack_ports.api}"
    lambda     = "http://localhost:${var.localstack_ports.api}"
    apigateway = "http://localhost:${var.localstack_ports.api}"
  }
}

module "llm_router" {
  source = "../../modules/llm_router/v0.1.0"
  
  environment     = var.environment
  name_prefix     = var.name_prefix
  lambda_zip_path = var.lambda_zip_path
  region          = var.region
  tags            = var.tags
  
  providers = {
    aws = aws.localstack
  }
}
