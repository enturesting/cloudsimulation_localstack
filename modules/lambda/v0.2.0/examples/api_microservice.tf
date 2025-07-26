# Example: API Microservice with Lambda, API Gateway, and DynamoDB
# This example shows how to build a complete serverless microservice

# DynamoDB table for the microservice
module "products_table" {
  source = "../../dynamodb/v0.2.0"
  
  table_name       = "products"
  hash_key         = "product_id"
  attribute_type   = "S"
  environment_name = "prod"
  
  # Global Secondary Index for category queries
  global_secondary_indexes = [
    {
      name            = "category-index"
      hash_key        = "category"
      range_key       = "created_at"
      projection_type = "ALL"
      read_capacity   = 10
      write_capacity  = 5
    }
  ]
  
  additional_attributes = [
    {
      name = "category"
      type = "S"
    },
    {
      name = "created_at"
      type = "S"
    }
  ]
  
  enable_sse = true
  
  tags = {
    Environment = "production"
    Service     = "product-api"
    Team        = "backend"
  }
}

# Lambda function for the API
module "products_api" {
  source = "../"
  
  function_name = "products-api"
  runtime      = "python3.9"
  handler      = "app.lambda_handler"
  filename     = "products_api.zip"
  
  # Environment variables
  environment_variables = {
    PRODUCTS_TABLE = module.products_table.table_name
    LOG_LEVEL      = "INFO"
    REGION         = "us-east-1"
  }
  
  # Lambda configuration
  timeout     = 30
  memory_size = 256
  
  # VPC configuration if needed
  vpc_config = {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }
  
  # Dead letter queue for error handling
  dead_letter_config = {
    target_arn = aws_sqs_queue.products_dlq.arn
  }
  
  tags = {
    Environment = "production"
    Service     = "product-api"
    Team        = "backend"
  }
}

# IAM role and policies for Lambda
resource "aws_iam_role" "products_api_role" {
  name = "products-api-lambda-role"
  
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
}

resource "aws_iam_role_policy" "products_api_policy" {
  name = "products-api-lambda-policy"
  role = aws_iam_role.products_api_role.id
  
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
        Resource = [
          module.products_table.table_arn,
          "${module.products_table.table_arn}/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage"
        ]
        Resource = aws_sqs_queue.products_dlq.arn
      }
    ]
  })
}

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "products_api_role_policy" {
  role       = aws_iam_role.products_api_role.name
  policy_arn = aws_iam_role_policy.products_api_policy.arn
}

# API Gateway for the microservice
module "products_api_gateway" {
  source = "../../api_gateway/v0.2.0"
  
  name             = "products-api"
  stage_name       = "v1"
  environment_name = "prod"
  
  # API configuration
  endpoints = [
    {
      path           = "/products"
      methods        = ["GET", "POST"]
      lambda_function = module.products_api.function_name
    },
    {
      path           = "/products/{id}"
      methods        = ["GET", "PUT", "DELETE"]
      lambda_function = module.products_api.function_name
    },
    {
      path           = "/products/category/{category}"
      methods        = ["GET"]
      lambda_function = module.products_api.function_name
    }
  ]
  
  # Enable CORS
  cors_enabled = true
  cors_origins = ["https://mycompany.com", "https://admin.mycompany.com"]
  
  # API throttling
  throttle_settings = {
    rate_limit  = 1000
    burst_limit = 2000
  }
  
  # Enable API caching
  caching_enabled = true
  cache_ttl      = 300  # 5 minutes
  
  tags = {
    Environment = "production"
    Service     = "product-api"
    Team        = "backend"
  }
}

# Dead Letter Queue for failed Lambda invocations
resource "aws_sqs_queue" "products_dlq" {
  name                      = "products-api-dlq"
  message_retention_seconds = 1209600  # 14 days
  
  tags = {
    Environment = "production"
    Service     = "product-api"
    Team        = "backend"
  }
}

# CloudWatch Log Group with retention
resource "aws_cloudwatch_log_group" "products_api_logs" {
  name              = "/aws/lambda/products-api"
  retention_in_days = 30
  
  tags = {
    Environment = "production"
    Service     = "product-api"
    Team        = "backend"
  }
}

# CloudWatch alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "products_api_errors" {
  alarm_name          = "products-api-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors lambda errors"
  alarm_actions       = [var.sns_alert_topic_arn]
  
  dimensions = {
    FunctionName = module.products_api.function_name
  }
  
  tags = {
    Environment = "production"
    Service     = "product-api"
    Team        = "backend"
  }
}

# Variables
variable "private_subnet_ids" {
  description = "List of private subnet IDs for Lambda VPC configuration"
  type        = list(string)
  default     = []
}

variable "lambda_security_group_id" {
  description = "Security group ID for Lambda function"
  type        = string
  default     = ""
}

variable "sns_alert_topic_arn" {
  description = "SNS topic ARN for alerts"
  type        = string
}

# Outputs
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.products_api_gateway.api_endpoint
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.products_api.function_arn
}

output "products_table_name" {
  description = "Name of the products DynamoDB table"
  value       = module.products_table.table_name
}