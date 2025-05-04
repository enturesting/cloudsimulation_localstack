# Note: access_key, secret_key, ami, and bucket_name are loaded from nonprod.auto.tfvars.json (ignored from Git)
# Those files either way
# nonprod.tfvars
table_name       = "NonprodSharedTable"
hash_key         = "ID"
attribute_type   = "S"
environment_name = "nonprod"
owner            = "nick"
instance_type    = "t3.micro"
enable_kms       = true
enable_vpc       = true
enable_ec2       = true
enable_sse       = true
enable_iam       = true
enable_api_gateway = true
enable_lambda    = true
lambda_function_name = "nonprod-api-handler"
api_gateway_name = "nonprod-api-gateway"
api_gateway_stage_name = "nonprod"
localstack_port  = 4567
user_data        = "#!/bin/bash\necho Hello from nonprod > /tmp/nonprod.txt"
common_tags = {
  Environment = "nonprod"
  Owner       = "nick"
}
