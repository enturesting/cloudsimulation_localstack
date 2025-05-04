output "key_id" {
  value       = aws_kms_key.this.key_id
  description = "KMS key ID"
}

# Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made
output "example_output" {
  value = "ok"
}
