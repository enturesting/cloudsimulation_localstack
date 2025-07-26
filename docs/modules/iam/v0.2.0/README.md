# 🔐 IAM Module

## Version: 0.2.0

Provisions an IAM role and policy suitable for local simulation using LocalStack. By default, this module grants basic `s3:ListAllMyBuckets` permissions and creates a trust relationship for EC2.

---

## 📥 Inputs

| Name              | Description                                  | Type          | Default |
|-------------------|----------------------------------------------|---------------|---------|
| `environment_name`| Environment name used as a prefix (e.g. dev) | `string`      | n/a     |
| `tags`            | Tags to apply to IAM resources               | `map(string)` | `{}`    |

---

## 📤 Outputs

| Name         | Description            |
|--------------|------------------------|
| `role_name`  | Name of the IAM role   |
| `example_output` | Static "ok" output (for Terratest MVP) |

---

## 🔐 Resources Created

- **IAM Role**: Named using `${environment_name}-role` with default EC2 trust policy.
- **IAM Policy**: Named `${environment_name}-policy` with permission to `s3:ListAllMyBuckets`.
- **Attachment**: Attaches the policy to the role.

---

## 🧪 Example Usage

```hcl
module "iam" {
  source = "../modules/iam"

  environment_name = "develop"
  tags = {
    Environment = "develop"
    Owner       = "nick"
  }

  providers = {
    aws = aws.localstack
  }
}
```

---

## 💡 Notes

- This module uses a hardcoded trust policy for EC2 service principal.
- The policy is basic and intended for test/demo use only.
- `example_output` exists for Terratest validation scaffolding and can be removed in later versions.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Environment name (dev, nonprod, etc.) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the IAM resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example_output"></a> [example\_output](#output\_example\_output) | Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | IAM role name |
<!-- END_TF_DOCS -->