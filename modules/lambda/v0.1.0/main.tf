# Module version: 0.1.0
# This version is in MVP phase and may have breaking changes
# For production use, wait for version 1.0.0

resource "aws_lambda_function" "this" {
  filename         = "${path.module}/lambda_function.zip"
  function_name    = var.function_name
  role             = var.role_arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  timeout          = var.timeout
  memory_size      = var.memory_size

  environment {
    variables = merge(var.environment_variables, {
      DYNAMODB_TABLE = var.dynamodb_table
    })
  }

  tags = var.tags
}

resource "aws_lambda_permission" "this" {
  count = var.allow_api_gateway && var.api_gateway_execution_arn != "" ? 1 : 0

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
} 