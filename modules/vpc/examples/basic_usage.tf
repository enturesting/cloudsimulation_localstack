# Example VPC module usage
# module "vpc" {
#   source     = "../vpc"
#   cidr_block = "10.0.0.0/16"
#   enable_dns_support = true
#   providers = {
#     aws = aws.localstack
#   }
# }