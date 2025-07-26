output "table_name" {
  value       = aws_dynamodb_table.this.name
  description = "DynamoDB table name"
}

output "table_arn" {
  value       = aws_dynamodb_table.this.arn
  description = "DynamoDB table ARN"
}

output "table_stream_arn" {
  value       = aws_dynamodb_table.this.stream_arn
  description = "DynamoDB table stream ARN"
}

# Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made
output "example_output" {
  value = "ok"
}
