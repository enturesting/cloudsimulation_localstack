# dev.tfvars
access_key       = "dev-access"
secret_key       = "dev-secret"
name             = "develop-vpc"
bucket_name      = "dev-shared-bucket"
table_name       = "DevSharedTable"
hash_key         = "ID"
attribute_type   = "S"
environment_name = "dev"
owner            = "nick"
instance_type    = "t3.micro"
ami              = "ami-9e8966cf"
enable_kms       = false
enable_vpc       = true
enable_ec2       = true
enable_sse       = true
enable_iam       = true
user_data        = "#!/bin/bash\necho Hello from dev > /tmp/dev.txt"
common_tags = {
  Environment = "dev"
  Owner       = "nick"
}
