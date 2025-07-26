variable "environment_name" {
  type        = string
  description = "Name of the environment (e.g. dev, nonprod)"
}

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