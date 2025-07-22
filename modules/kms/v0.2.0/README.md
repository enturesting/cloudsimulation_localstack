# 🔐 KMS Module

## Version: 0.2.0

This module simulates a KMS key and related configuration.

## 🚧 Work in Progress

Full input/output documentation will be filled in soon.

## 📥 Inputs

| Name              | Description                     | Type   | Default |
|-------------------|---------------------------------|--------|---------|
| `enable_key_rotation` | Enable key rotation         | bool   | false   |
| `description`     | Description for the key         | string | `""`    |

## 📤 Outputs

| Name        | Description               |
|-------------|---------------------------|
| `key_id`    | ID of the created key     |
| `key_arn`   | ARN of the KMS key        |

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
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Environment name (dev, nonprod, etc.) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the KMS key | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example_output"></a> [example\_output](#output\_example\_output) | Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | KMS key ID |
<!-- END_TF_DOCS -->