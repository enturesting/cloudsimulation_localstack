# ✅ Terraform Module Testing with Terratest (Go)

This folder contains early-stage [Terratest](https://terratest.gruntwork.io/) tests written in Go to validate infrastructure modules using LocalStack.

## 🧪 Current Test Coverage

| Test File        | Module Tested |
|------------------|---------------|
| `ec2_test.go`    | EC2 module (launch success) |
| `dynamo_test.go` | DynamoDB table creation |
| `s3_test.go`     | S3 bucket creation |
| `kms_test.go`    | KMS key generation |
| `iam_test.go`    | IAM role creation |
| `vpc_test.go`    | VPC provisioning (WIP) |

> Each test initializes Terraform with environment variables pointing to LocalStack and verifies basic resource creation without hitting real AWS APIs.

---

## ▶️ Running Tests Locally

Requires Go installed locally:

```bash
cd test
go mod tidy   # first time only
go test -v
```

## 🛠️ Requirements
- Go 1.19+ installed
- LocalStack Pro running (localhost:4566)
- Terraform modules initialized
- Environment variables or .tfvars for credentials

## 🔭 Next Steps
- dd cleanup/teardown validation
- Add negative test cases (e.g. invalid AMIs)
- Support for tagging checks, outputs, and module assertions
- Expand VPC test coverage (subnets, routes, NAT, etc.)

## 📦 Related
`.github/workflows/act-test.yml` - CI workflow for running these tests locally using act