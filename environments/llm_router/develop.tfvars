# Note: access_key, secret_key, ami, and bucket_name are loaded from develop.auto.tfvars.json (ignored from Git)

environment = "develop"
name_prefix = "llm-router-dev"
lambda_zip_path = "../../lambda/llm-router.zip"

tags = {
  Environment = "develop"
  Project     = "LLM-Router"
  ManagedBy   = "Terraform"
}

region = "us-east-1"

environment_name = "llm_router"
owner            = "nick"
state_bucket     = "your-state-bucket-name"
localstack_ports = {
  api = 4566
  ui  = 31566
}

common_tags = {
  Environment = "llm_router"
  Owner       = "nick"
}
