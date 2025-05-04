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
