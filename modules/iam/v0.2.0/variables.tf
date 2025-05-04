variable "environment_name" {
  type        = string
  description = "Environment name (dev, nonprod, etc.)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the IAM resources"
  default     = {}
}
