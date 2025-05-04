# Example IAM module usage
# module "iam_role" {
#   source             = "../iam"
#   role_name          = "app-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
#   providers = {
#     aws = aws.localstack
#   }
# }
