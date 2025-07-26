output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "S3 bucket name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "S3 bucket ARN"
}

# Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made
output "example_output" {
  value = "ok"
}
