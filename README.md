# 🛠️ LocalStack Terraform Demo Lab

This project simulates a multi-environment AWS setup (`develop`, `nonprod`) using:
- **Terraform** with modular, reusable infrastructure
- **LocalStack Pro** for AWS API simulation
- **Rancher Desktop** with **dockerd** as the container engine
- **GitHub Actions** for CI + local testing via [`act`](https://github.com/nektos/act)
- **Terratest** (Go) for infrastructure test automation


[![Terraform](https://img.shields.io/badge/IaC-Terraform-blue)](https://www.terraform.io/)
[![LocalStack](https://img.shields.io/badge/Simulated-AWS-lightgrey)](https://localstack.cloud)
[![CI](https://github.com/enturesting/cloudsimulation_localstack/actions/workflows/terraform-test.yml/badge.svg)](https://github.com/enturesting/cloudsimulation_localstack/actions)

---

## 📁 Folder Structure

```bash
tf-project-root/
├── modules/                  # Reusable Terraform modules
│   ├── app_stack/   # (WIP) Composable app infrastructure (IAM, EC2, S3, Dynamo)
│   ├── s3/
│   ├── ec2/
│   ├── dynamodb/
│   ├── iam/                  # Optional IAM module
│   ├── kms/                  # Optional KMS key module
│   └── vpc/                  # Optional VPC module
├── environments/            # Shared environment configurations
│   ├── develop.tfvars
│   ├── nonprod.tfvars
│   ├── main.tf              # Shared entrypoint for Terraform environments
│   ├── variables.tf         # Shared variables across environments
│   └── outputs.tf           # Shared environment outputs
├── scripts/                 # PowerShell & Bash automation helpers
│   ├── apply_env.ps1        # Deploy Terraform with selected .tfvars file
│   ├── reset_localstack.ps1 # Stop/remove container, wipe volume, restart
│   ├── clean-reset.ps1      # Destroy Terraform + LocalStack resources (no restart)
│   └── register_mock_ami.ps1 # Register mock AMIs for LocalStack EC2
│   └── register_mock_ami.sh  # Register mock AMIs for LocalStack EC2 (bash version)
├── .github/
│   └── workflows/
│       └── act-test.yml     # GitHub Actions workflow for LOCAL CI/Terratest using ACT
│       └── terraform-test.yml  # GitHub Actions workflow for Github Push CI/Terratest
├── test/
│   └── ec2_test.go          # Example Terratest file (Go)
│   └── dynamo_test.go       # Example Terratest file (Go)
│   └── vpc_test.go          # Example Terratest file (Go)
│   └── iam_test.go          # Example Terratest file (Go)
│   └── s3_test.go           # Example Terratest file (Go)
│   └── kms_test.go          # Example Terratest file (Go)
├── docs/                    # Placeholder for Docsify local module registry
└── README.md

```

---

## 🚀 Deploy an Environment
```powershell
# From project root:
.\scripts\apply_env.ps1 -env develop     # or -env nonprod
```
This will:
- Load access keys and provider configs
- Initialize + plan Terraform with environments/main.tf
- Load conditional modules like EC2, IAM, VPC, and KMS based on .tfvars
- Prompt before applying

## ⚙️ Register a Mock AMI (for EC2 module testing)
`.\scripts\register_mock_ami.ps1 -Env develop`
Creates a mock AMI on LocalStack and writes it to the .auto.tfvars.json file to simulate EC2 launch scenarios.
⚠️ Known Issue: AWS CLI sometimes rejects the JSON input. Fixes may require ConvertTo-Json -Depth 5 or manual editing.

## 🧪 Run Tests Locally via act
`act -W .github/workflows/act-test.yml`
- This simulates your GitHub Actions pipeline locally:
- Lints and formats Terraform code
- Runs Terratest (Go)
- Validates mock AMI registration
- Supports environment matrix (feature, develop, nonprod)

## 🔐 Handling Credentials and Secrets

Terraform loads credentials from environment-specific `.auto.tfvars.json` files which are **excluded from version control** via `.gitignore`.

Example:
- `develop.auto.tfvars.json.example` is provided with safe dummy values for LocalStack use
- To use: copy and modify locally

```bash
cp environments/develop.auto.tfvars.json.example environments/develop.auto.tfvars.json

---

┌────────────────────────────────────┐
│  develop.tfvars                    │
│  - static inputs (AMI, flags)      │
│  - NO credentials                  │
└──────────────┬─────────────────────┘
               │
┌──────────────▼─────────────────────┐
│  develop.auto.tfvars.json         │
│  - local dummy secrets & ids      │
│  - not checked into Git           │
└──────────────┬─────────────────────┘
               │
        ┌──────▼──────┐
        │  main.tf    │ → Loads both files
        └─────────────┘
               │
     ┌─────────▼─────────┐
     │ LocalStack Apply  │ → Creates VPC, IAM, EC2, etc.
     └───────────────────┘

## 🧼 Cleanup Scripts
| Script Name            | Purpose                                  | Actions Taken                                                                  | Restarts Docker |
|------------------------|------------------------------------------|----------------------------------------------------------------------------------|-----------------|
| `reset_localstack.ps1` | Resets LocalStack runtime + volume       | Stops/removes the container, clears volume, restarts with multi-account support | ✅ Yes          |
| `clean-reset.ps1`      | Cleans Terraform & LocalStack resources  | Destroys S3 buckets, DynamoDB tables, schedules KMS deletion                   | ❌ No           |

> Use `clean-reset.ps1 -env develop` before a clean deploy.

---

## 🔍 Manual Terraform Commands
```bash
cd environments

terraform init
terraform plan -var-file="develop.tfvars"
terraform apply -var-file="develop.tfvars"

# Switch to nonprod
terraform plan -var-file="nonprod.tfvars"
terraform apply -var-file="nonprod.tfvars"
```

---

## 🔧 LocalStack Notes
- Port **4566**: main LocalStack gateway for AWS APIs
- Port **31566**: LocalStack Web UI only
- Credentials are stored locally in `.tfvars` and also injected from GitHub Actions environment-specific secrets
- Multi-account mode enabled via `LS_PLATFORM_MULTI_ACCOUNT=true`
- LocalStack UI may still group all environments under one account visually
---

## ✨ Future Enhancements
- Add shared tagging logic via locals
- Add version constraints + module registries
- Use `locals` for tag standardization
- Create apply_env.sh for macOS/Linux parity
- Add backend block (e.g., S3) to simulate remote state
- Create `apply_env.sh` for Linux/macOS compatibility
- Add VPC networking tests and log analysis
- Automate publishing module docs with Docsify
- Expand test coverage (e.g., more AWS services, error scenarios)
- Enforce tagging/validation across all modules
- Publish GitHub Action as reusable workflow

## ⚠️ Known Issues
- LocalStack UI may not visually separate environments, even with unique credentials (in coming update)
- `aws_s3_bucket_v2` may fail if LocalStack version or Terraform provider doesn't fully support it
- Terratest requires Go installed + configured locally

## 📦 Requirements

- Terraform CLI v1.5+
- LocalStack Pro (Docker)
- Go (for Terratest)
- PowerShell (for Windows) or Bash (for Linux/macOS)
- GitHub Actions / [act](https://github.com/nektos/act)
