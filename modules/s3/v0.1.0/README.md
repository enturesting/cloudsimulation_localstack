# 🪣 S3 Module

## Version: 0.1.0

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