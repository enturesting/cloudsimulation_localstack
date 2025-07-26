output "role_name" {
  value       = aws_iam_role.this.name
  description = "IAM role name"
}

# Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made
output "example_output" {
  value = "ok"
}
