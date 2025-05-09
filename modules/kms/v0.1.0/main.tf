resource "aws_kms_key" "this" {
  description             = "KMS key for ${var.environment_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}
