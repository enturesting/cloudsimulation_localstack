resource "aws_dynamodb_table" "this" {
  name         = "${var.environment_name}SharedTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = var.attribute_type
  }

  dynamic "server_side_encryption" {
    for_each = var.enable_sse ? [1] : []
    content {
      enabled = true
    }
  }

  tags = var.tags
}

