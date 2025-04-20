# nonprod.tfvars
access_key       = "nonprod-access"
secret_key       = "nonprod-secret"
bucket_name      = "nonprod-shared-bucket"
table_name       = "NonprodSharedTable"
name             = "nonprod-vpc"
hash_key         = "ID"
attribute_type   = "S"
environment_name = "nonprod"
owner            = "nick"
instance_type    = "t3.micro"
ami              = "ami-8bb3cda6"
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
