output "rest_api_id" {
  description = "The ID of the REST API"
  value       = aws_api_gateway_rest_api.this.id
}

output "root_resource_id" {
  description = "The resource ID of the REST API's root"
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "resource_id" {
  description = "The resource ID of the API Gateway resource"
  value       = aws_api_gateway_resource.this.id
}

output "execution_arn" {
  description = "The execution ARN part to be used in lambda_permission's source_arn"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "invoke_url" {
  description = "The URL to invoke the API Gateway"
  value       = "${aws_api_gateway_stage.this.invoke_url}/${var.path}"
}

output "stage_arn" {
  description = "The ARN of the stage"
  value       = aws_api_gateway_stage.this.arn
} 