variable "table_name" {
  type        = string
  description = "Name of the DynamoDB table"
}

variable "hash_key" {
  type        = string
  description = "Primary hash key for the table"
}

variable "attribute_type" {
  type        = string
  description = "Attribute type for the hash key (e.g., S, N, B)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the table"
  default     = {}
}

variable "enable_sse" {
  type        = bool
  description = "Enable server-side encryption"
  default     = true
}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
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

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
