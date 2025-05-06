terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
      configuration_aliases = [aws.localstack]
    }
  }
}

locals {
  name_prefix = var.name_prefix != null ? var.name_prefix : "llm-router"
}

# DynamoDB Table
resource "aws_dynamodb_table" "conversation_history" {
  provider = aws.localstack
  name     = "${local.name_prefix}-conversations"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"
  range_key      = "timestamp"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  tags = var.tags
}

# Lambda Function
resource "aws_lambda_function" "router" {
  provider = aws.localstack
  filename         = var.lambda_zip_path
  function_name    = "${local.name_prefix}-router"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "nodejs18.x"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      CONVERSATION_TABLE = aws_dynamodb_table.conversation_history.name
    }
  }

  tags = var.tags
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  provider = aws.localstack
  name = "${local.name_prefix}-lambda-role"

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

  tags = var.tags
}

# Lambda IAM Policy
resource "aws_iam_role_policy" "lambda_policy" {
  provider = aws.localstack
  name = "${local.name_prefix}-lambda-policy"
  role = aws_iam_role.lambda_role.id

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
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.conversation_history.arn
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
}

# API Gateway
resource "aws_apigatewayv2_api" "api" {
  provider = aws.localstack
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age      = 300
  }
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "stage" {
  provider = aws.localstack
  api_id = aws_apigatewayv2_api.api.id
  name   = var.environment
  auto_deploy = true
}

# API Gateway Integration
resource "aws_apigatewayv2_integration" "lambda" {
  provider = aws.localstack
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "Lambda integration"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.router.invoke_arn
}

# API Gateway Route
resource "aws_apigatewayv2_route" "route" {
  provider = aws.localstack
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /chat"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Lambda Permission
resource "aws_lambda_permission" "api_gw" {
  provider     = aws.localstack
  statement_id = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.router.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
} 