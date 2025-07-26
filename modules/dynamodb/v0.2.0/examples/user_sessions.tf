# Example: User Session Store with DynamoDB
# This example shows how to use the DynamoDB module for managing user sessions

module "user_sessions" {
  source = "../"
  
  table_name       = "user-sessions"
  hash_key         = "session_id"
  attribute_type   = "S"
  environment_name = "prod"
  
  # Enable TTL for automatic session cleanup
  ttl_enabled      = true
  ttl_attribute    = "expires_at"
  
  # Configure read/write capacity for session workload
  billing_mode     = "PROVISIONED"
  read_capacity    = 100
  write_capacity   = 50
  
  # Enable auto-scaling
  auto_scaling = {
    read = {
      min_capacity     = 50
      max_capacity     = 500
      target_value     = 70
      scale_in_cooldown  = 60
      scale_out_cooldown = 60
    }
    write = {
      min_capacity     = 25
      max_capacity     = 250
      target_value     = 70
      scale_in_cooldown  = 60
      scale_out_cooldown = 60
    }
  }
  
  # Global Secondary Index for querying by user_id
  global_secondary_indexes = [
    {
      name            = "user-id-index"
      hash_key        = "user_id"
      projection_type = "ALL"
      read_capacity   = 50
      write_capacity  = 25
    }
  ]
  
  # Additional attributes
  additional_attributes = [
    {
      name = "user_id"
      type = "S"
    }
  ]
  
  # Enable point-in-time recovery
  enable_point_in_time_recovery = true
  
  # Enable server-side encryption
  enable_sse = true
  kms_key_id = var.session_kms_key_id
  
  tags = {
    Environment = "production"
    Purpose     = "user-sessions"
    Team        = "backend"
    Compliance  = "GDPR"
  }
}

# Example Lambda function for session management
resource "aws_lambda_function" "session_manager" {
  filename         = "session_manager.zip"
  function_name    = "user-session-manager"
  role            = aws_iam_role.session_lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30
  
  environment {
    variables = {
      SESSIONS_TABLE = module.user_sessions.table_name
      TTL_HOURS      = "24"
    }
  }
}

# IAM role for Lambda function
resource "aws_iam_role" "session_lambda_role" {
  name = "session-manager-lambda-role"
  
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

resource "aws_iam_role_policy" "session_lambda_policy" {
  name = "session-manager-lambda-policy"
  role = aws_iam_role.session_lambda_role.id
  
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
          "dynamodb:Query"
        ]
        Resource = [
          module.user_sessions.table_arn,
          "${module.user_sessions.table_arn}/index/*"
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
      }
    ]
  })
}

# Variables
variable "session_kms_key_id" {
  description = "KMS key ID for session table encryption"
  type        = string
}

# Outputs
output "sessions_table_name" {
  description = "Name of the user sessions table"
  value       = module.user_sessions.table_name
}

output "sessions_table_arn" {
  description = "ARN of the user sessions table"
  value       = module.user_sessions.table_arn
}

output "session_lambda_arn" {
  description = "ARN of the session manager Lambda function"
  value       = aws_lambda_function.session_manager.arn
}