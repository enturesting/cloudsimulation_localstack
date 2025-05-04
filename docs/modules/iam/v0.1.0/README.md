# 🔐 IAM Module

## Version: 0.1.0

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
