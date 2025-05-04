data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

module "iam" {
  source = "../../../"

  name             = "example-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
