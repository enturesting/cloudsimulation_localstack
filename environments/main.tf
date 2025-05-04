# main.tf (shared entrypoint)

locals {
  selected_subnet_id = (var.enable_vpc && length(module.vpc) > 0) ? module.vpc[0].public_subnet_ids[0] : ""
  selected_sg_ids    = (var.enable_vpc && length(module.vpc) > 0) ? [module.vpc[0].default_sg] : []
}

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
    s3       = "http://localhost:${var.localstack_port}"
    dynamodb = "http://localhost:${var.localstack_port}"
    ec2      = "http://localhost:${var.localstack_port}"
    iam      = "http://localhost:${var.localstack_port}"
    kms      = "http://localhost:${var.localstack_port}"
    sts      = "http://localhost:${var.localstack_port}"
    lambda   = "http://localhost:${var.localstack_port}"
    apigateway = "http://localhost:${var.localstack_port}"
  }
}

module "s3_bucket" {
  source           = "../modules/s3/v0.1.0"
  bucket_name      = "${var.environment_name}-terraform-test-bucket"
  environment_name = var.environment_name
  providers = {
    aws = aws.localstack
  }
}

module "dynamodb_table" {
  source           = "../modules/dynamodb/v0.1.0"
  table_name       = var.table_name
  hash_key         = var.hash_key
  environment_name = var.environment_name
  attribute_type   = var.attribute_type
  tags             = var.common_tags
  enable_sse       = var.enable_sse
  providers = {
    aws = aws.localstack
  }
}

module "vpc" {
  count              = var.enable_vpc ? 1 : 0
  source             = "../modules/vpc/v0.1.0"
  tags               = var.common_tags
  availability_zones = ["us-east-1a", "us-east-1b"]
  providers = {
    aws = aws.localstack
  }
}

output "debug_vpc_output_sg" {
  value = module.vpc[0].default_sg
}

output "debug_vpc_output_subnet" {
  value = module.vpc[0].public_subnet_ids
}

module "ec2_instance" {
  count           = var.enable_ec2 ? 1 : 0
  source          = "../modules/ec2/v0.1.0"
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  user_data       = var.user_data
  key_name        = var.key_name
  subnet_id       = local.selected_subnet_id
  security_groups = local.selected_sg_ids
  providers = {
    aws = aws.localstack
  }
}

module "kms" {
  count            = var.enable_kms ? 1 : 0
  source           = "../modules/kms/v0.1.0"
  environment_name = var.environment_name
  tags             = var.common_tags
  providers = {
    aws = aws.localstack
  }
}

module "iam" {
  count            = var.enable_iam ? 1 : 0
  source           = "../modules/iam/v0.1.0"
  environment_name = var.environment_name
  tags             = var.common_tags
  providers = {
    aws = aws.localstack
  }
}

resource "aws_iam_role" "lambda_role" {
  count = var.enable_lambda ? 1 : 0
  name = "${var.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  provider = aws.localstack
}

resource "aws_iam_role_policy" "lambda_policy" {
  count = var.enable_lambda ? 1 : 0
  name = "${var.lambda_function_name}-policy"
  role = aws_iam_role.lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  provider = aws.localstack
}

module "lambda" {
  count            = var.enable_lambda ? 1 : 0
  source           = "../modules/lambda/v0.1.0"
  function_name    = var.lambda_function_name
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  filename         = "${path.module}/../modules/lambda/lambda_function.zip"
  role_arn         = aws_iam_role.lambda_role[0].arn
  dynamodb_table   = module.dynamodb_table.table_name
  tags             = var.common_tags
  providers = {
    aws = aws.localstack
  }
}

module "api_gateway" {
  count            = var.enable_api_gateway ? 1 : 0
  source           = "../modules/api_gateway/v0.1.0"
  name             = var.api_gateway_name
  stage_name       = var.api_gateway_stage_name
  path             = var.api_gateway_path
  methods          = var.api_gateway_methods
  lambda_invoke_arn = var.enable_lambda ? module.lambda[0].invoke_arn : ""
  environment_name = var.environment_name
  tags             = var.common_tags
  providers = {
    aws = aws.localstack
  }
}