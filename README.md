# 🛠️ LocalStack Terraform Demo Lab

This project simulates a multi-environment AWS setup (`dev`, `nonprod`) using:
- **Terraform** with modular, reusable infrastructure
- **LocalStack Pro** for AWS API simulation
- **Rancher Desktop** with **dockerd** as the container engine

---

## 📁 Folder Structure

```bash
tf-project-root/
├── modules/                  # Reusable Terraform modules
│   ├── s3/
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── ec2/
│   │   ├── main.tf
│   │   └── outputs.tf
│   └── dynamodb/
│       ├── main.tf
│       └── outputs.tf
├── environments/            # Environment configs
│   ├── dev.tfvars
│   ├── nonprod.tfvars
│   ├── main.tf               # Shared main entrypoint
│   └── variables.tf          # Shared variable declarations, supports conditional module loading
├── scripts/                 # Automation and helper scripts
│   ├── apply_env.ps1        # Deploy per environment
│   ├── reset_localstack.ps1 # Reset Docker container
│   ├── clean-reset.ps1      # Cleanup Terraform state & LocalStack data
│   └── register_mock_ami.ps1 # In progress: registers mock AMIs for EC2 module testing in LocalStack
└── README.md
```

---

## 🚀 Deploy an Environment
```powershell
# From project root:
.\scripts\apply_env.ps1 -env dev     # or -env nonprod
```
This will:
- Load the correct credentials for the environment
- Initialize and plan Terraform using the shared `main.tf`
- Load conditional modules like EC2, IAM, VPC, and KMS based on .tfvars
- Prompt before applying


---

## 🧼 Cleanup Scripts
| Script Name            | Purpose                                  | Actions Taken                                                                  | Restarts Docker |
|------------------------|------------------------------------------|----------------------------------------------------------------------------------|-----------------|
| `reset_localstack.ps1` | Resets LocalStack runtime + volume       | Stops/removes the container, clears volume, restarts with multi-account support | ✅ Yes          |
| `clean-reset.ps1`      | Cleans Terraform & LocalStack resources  | Destroys S3 buckets, DynamoDB tables, schedules KMS deletion                   | ❌ No           |

> Use `clean-reset.ps1 -env dev` before a clean deploy.

---

## 🔍 Manual Terraform Commands
```bash
cd environments

terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"

# Switch to nonprod
terraform plan -var-file="nonprod.tfvars"
terraform apply -var-file="nonprod.tfvars"
```

---

## 🔧 LocalStack Notes
- Port **4566**: main LocalStack gateway for AWS APIs
- Port **31566**: LocalStack Web UI only
- Credentials (access/secret keys) are configured in `.tfvars` and auto-injected
- Multi-account mode enabled via `LS_PLATFORM_MULTI_ACCOUNT=true`
LocalStack UI may still group all environments under one account visually
---

## ✨ Future Enhancements
- Add `outputs.tf` in each module to expose useful values
- Use `locals` for tag standardization
- Add backend block (e.g., S3) to simulate remote state
- Add VPC, IAM, and KMS modules with conditional creation
- Create `apply_env.sh` for Linux/macOS compatibility
- Expand test coverage (e.g., more AWS services, error scenarios)

## ⚠️ Known Issues
- `register_mock_ami.ps1` may fail with "Invalid JSON" or `cli-input-json` errors due to escaping or AWS CLI expectations
- LocalStack UI may not visually separate environments, even with unique credentials
- `aws_s3_bucket_v2` may fail if LocalStack version or Terraform provider doesn't fully support it