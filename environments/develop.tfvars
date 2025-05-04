# Note: access_key, secret_key, ami, and bucket_name are loaded from develop.auto.tfvars.json (ignored from Git)

# dev.tfvars
table_name       = "DevSharedTable"
hash_key         = "ID"
attribute_type   = "S"
environment_name = "dev"
owner            = "nick"
instance_type    = "t3.micro"
enable_kms       = false
enable_vpc       = true
enable_ec2       = true
enable_sse       = true
enable_iam       = true
enable_api_gateway = true
enable_lambda    = true
lambda_function_name = "dev-api-handler"
api_gateway_name = "dev-api-gateway"
api_gateway_stage_name = "dev"
user_data        = "#!/bin/bash\necho Hello from dev > /tmp/dev.txt"
common_tags = {
  Environment = "dev"
  Owner       = "nick"
}
