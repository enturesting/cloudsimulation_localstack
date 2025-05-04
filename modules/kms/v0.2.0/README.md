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
