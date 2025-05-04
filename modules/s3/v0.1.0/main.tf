resource "aws_s3_bucket" "this" {
  bucket = "${var.environment_name}-terraform-test-bucket"

  tags = {
    Environment = "local"
    ManagedBy   = "Terraform"
  }
}
