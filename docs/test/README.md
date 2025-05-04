# ✅ Terraform Module Testing with Terratest (Go)

This folder contains early-stage [Terratest](https://terratest.gruntwork.io/) tests written in Go to validate Terraform infrastructure modules using LocalStack.

---

## 🧪 Current Test Coverage

| Test File        | Module Tested               |
|------------------|-----------------------------|
| `ec2_test.go`    | EC2 instance launch success |
| `dynamo_test.go` | DynamoDB table creation     |
| `s3_test.go`     | S3 bucket creation          |
| `kms_test.go`    | KMS key generation          |
| `iam_test.go`    | IAM role creation           |
| `vpc_test.go`    | VPC provisioning (WIP)      |

> Each test initializes Terraform with environment variables pointing to LocalStack and verifies resource creation — without hitting real AWS APIs.

---

## ▶️ Running Tests Locally

Requires Go installed:

```bash
cd test
go mod tidy   # First time only
go test -v
```

---

## 🛠️ Requirements

- Go 1.19+ installed
- LocalStack Pro running (`localhost:4566`)
- Terraform modules initialized (see `/modules`)
- Environment variables or `.tfvars` to supply credentials

---

## 🔭 Next Steps

- [ ] Add cleanup/teardown validation
- [ ] Add negative test cases (e.g., invalid AMIs)
- [ ] Support for output value assertions and tag validation
- [ ] Expand VPC test coverage (subnets, routing, NAT, etc.)

---

## 📦 Related

- `.github/workflows/act-test.yml` – Local CI test runner (via `act`)
- `.github/workflows/terraform-test.yml` – GitHub Actions test matrix
