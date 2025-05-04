variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "environment_name" {
  type        = string
  description = "Name of the environment (e.g. dev, nonprod)"
}