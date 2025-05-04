resource "aws_iam_role" "this" {
  name = "${var.environment_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "this" {
  name        = "${var.environment_name}-policy"
  description = "Policy for ${var.environment_name} role"
  policy      = data.aws_iam_policy_document.basic.json
}

data "aws_iam_policy_document" "basic" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
