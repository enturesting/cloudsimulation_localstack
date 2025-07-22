# 🗃️ DynamoDB Module

## Version: 0.2.0

Creates a DynamoDB table for simulated environments using LocalStack or AWS. Supports configurable hash key, attribute type, tags, and optional server-side encryption (SSE).

---

## 📥 Inputs

| Name              | Description                                           | Type          | Default  |
|-------------------|-------------------------------------------------------|---------------|----------|
| `environment_name`| Name of the environment (e.g., `develop`, `nonprod`) | `string`      | n/a      |
| `table_name`      | Logical name of the table                             | `string`      | n/a      |
| `hash_key`        | Name of the primary hash key                          | `string`      | n/a      |
| `attribute_type`  | Type of the hash key attribute (`S`, `N`, or `B`)     | `string`      | n/a      |
| `tags`            | Tags to apply to the DynamoDB table                   | `map(string)` | `{}`     |
| `enable_sse`      | Whether to enable server-side encryption              | `bool`        | `true`   |

---

## 📤 Outputs

| Name               | Description                         |
|--------------------|-------------------------------------|
| `table_name`       | Name of the created table           |
| `table_arn`        | ARN of the DynamoDB table           |
| `table_stream_arn` | Stream ARN (if streams are enabled) |
| `example_output`   | Static "ok" value (placeholder)     |

---

## 🧪 Example Usage

```hcl
module "dynamodb_table" {
  source         = "../modules/dynamodb"
  environment_name = "develop"
  table_name     = "DevSharedTable"
  hash_key       = "ID"
  attribute_type = "S"
  enable_sse     = true

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

## ℹ️ Notes

- This module currently supports a single `hash_key` (no sort key).
- Server-side encryption is conditionally added using `dynamic` blocks.
- Stream configuration is not enabled by default but can be added if needed.
- The `example_output` is used for Terratest scaffolding and will be removed in a future version.

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
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attribute_type"></a> [attribute\_type](#input\_attribute\_type) | Attribute type for the hash key (e.g., S, N, B) | `string` | n/a | yes |
| <a name="input_enable_sse"></a> [enable\_sse](#input\_enable\_sse) | Enable server-side encryption | `bool` | `true` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the environment (e.g. dev, nonprod) | `string` | n/a | yes |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | Primary hash key for the table | `string` | n/a | yes |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Name of the DynamoDB table | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the table | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example_output"></a> [example\_output](#output\_example\_output) | Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made |
| <a name="output_table_arn"></a> [table\_arn](#output\_table\_arn) | DynamoDB table ARN |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | DynamoDB table name |
| <a name="output_table_stream_arn"></a> [table\_stream\_arn](#output\_table\_stream\_arn) | DynamoDB table stream ARN |
<!-- END_TF_DOCS -->