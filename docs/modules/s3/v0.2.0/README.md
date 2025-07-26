# 🪣 S3 Module

## Version: 0.2.0

Provisions a local-compatible S3 bucket for testing with LocalStack or AWS-like environments. Includes support for tagging and environment-based naming conventions.

---

## 📥 Inputs

| Name              | Description                                   | Type          | Default | Required |
|-------------------|-----------------------------------------------|---------------|---------|----------|
| `bucket_name`     | Name of the S3 bucket (used internally only)  | `string`      | n/a     | ✅        |
| `environment_name`| Name of the environment (e.g. dev, nonprod)   | `string`      | n/a     | ✅        |

---

## 📤 Outputs

| Name            | Description             |
|-----------------|-------------------------|
| `bucket_name`   | Name of the S3 bucket   |
| `bucket_arn`    | ARN of the S3 bucket    |
| `example_output`| Static "ok" (for testing MVPs) |

---

## 🔧 Behavior

- The actual bucket name will be constructed as:  
  `${environment_name}-terraform-test-bucket`
- Tags applied:
  - `Environment = "local"`
  - `ManagedBy = "Terraform"`

---

## 🧪 Example Usage

```hcl
module "s3_bucket" {
  source           = "../modules/s3"
  bucket_name      = "placeholder" # not used directly in resource
  environment_name = "develop"

  providers = {
    aws = aws.localstack
  }
}
```

---

## 🚫 Security Notes

- Buckets are private by default.
- No ACLs or policies are applied unless extended.
- This is a test/development module and not intended for production workloads.

---

## 🧪 Testing

Run the tests using:

```bash
go test -v ./modules/s3/test/
```

---

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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the environment (e.g. dev, nonprod) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | S3 bucket ARN |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | S3 bucket name |
| <a name="output_example_output"></a> [example\_output](#output\_example\_output) | Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made |
<!-- END_TF_DOCS -->