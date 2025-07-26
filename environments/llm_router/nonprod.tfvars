# Note: access_key, secret_key, ami, and bucket_name are loaded from develop.auto.tfvars.json (ignored from Git)

environment = "nonprod"
name_prefix = "llm-router-nonprod"
lambda_zip_path = "../../lambda/llm-router.zip"

tags = {
  Environment = "nonprod"
  Project     = "LLM-Router"
  ManagedBy   = "Terraform"
}

region = "us-east-1"
# Note: localstack_endpoint is not set for nonprod as it's a real AWS environment
