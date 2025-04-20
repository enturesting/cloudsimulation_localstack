# Note: access_key, secret_key, name, ami, and bucket_name are loaded from nonprod.auto.tfvars.json (ignored from Git)
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
user_data        = "#!/bin/bash\necho Hello from nonprod > /tmp/nonprod.txt"
common_tags = {
  Environment = "nonprod"
  Owner       = "nick"
}
