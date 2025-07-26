output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "The ARN to be used for invoking the Lambda function from API Gateway"
  value       = aws_lambda_function.this.invoke_arn
}

output "qualified_arn" {
  description = "The ARN identifying your Lambda Function Version"
  value       = aws_lambda_function.this.qualified_arn
} 