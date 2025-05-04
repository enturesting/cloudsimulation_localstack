# 🛠️ LocalStack Terraform Demo Lab

> **Announcement (v0.1.0):**
> 
> This is the first stable MVP version of the project, now using semantic versioning for all modules! The infrastructure and Docsify documentation build successfully locally, and the new versioning strategy is in place. Use the `bump_module_version.ps1` script in `/scripts` to create new module versions as you iterate. See the README and Docsify landing page for details.

🌐 [View Module Registry Docs](https://enturesting.github.io/cloudsimulation_localstack/)

This repo contains modular Terraform components for use with LocalStack, including Docsify-based documentation, Terratest, and CI automation.

This repository simulates a multi-environment AWS setup using:
- 🧱 **Modular Terraform** infrastructure (`develop`, `nonprod`)
- 🧪 **Terratest in Go** and **Python Tests** for infrastructure validation
- 🐳 **LocalStack Pro** for AWS API emulation
- ⚙️ **Rancher Desktop** with `dockerd` as container engine
- 🔁 **CI/CD** using GitHub Actions and [`act`](https://github.com/nektos/act)
- 📚 **Docsify** for module registry UI and local module documentation

[![Terraform](https://img.shields.io/badge/IaC-Terraform-blue)](https://www.terraform.io/)
[![LocalStack](https://img.shields.io/badge/Simulated-AWS-lightgrey)](https://localstack.cloud)
[![CI](https://github.com/enturesting/cloudsimulation_localstack/actions/workflows/terraform-test.yml/badge.svg)](https://github.com/enturesting/cloudsimulation_localstack/actions)

---

## 📁 Project Structure

```bash
cloudsimulation_localstack/
├── modules/
│   ├── api_gw/             # API Gateway module
│   ├── lambda/             # Lambda function module
│   ├── dynamodb/           # Fully documented and tested module
│   ├── ec2/
│   ├── iam/
│   ├── kms/
│   ├── s3/
│   └── vpc/
├── environments/
│   ├── develop.tfvars
│   ├── nonprod.tfvars
│   ├── main.tf
│   ├── variables.tf / outputs.tf
│   └── README.md
├── scripts/
│   ├── apply_env.ps1
│   ├── bootstrap_dev_env.ps1
│   ├── clean-reset.ps1 / reset_localstack.ps1
│   ├── lint-terraform.ps1
│   ├── register_mock_ami.ps1 / .sh
│   ├── sync_all_docsify_readmes.ps1
│   ├── validate-metadata.ps1 / ci_docs_validate.ps1
│   ├── bash_mvp/                    # Bash versions of all PowerShell scripts (in development)
│   └── README.sh
├── .github/workflows/
│   └── terraform-test.yml / act-test.yml
├── test/
│   ├── python/              # Python-based tests
│   │   ├── iam_test.py
│   │   ├── kms_test.py
│   │   ├── s3_test.py
│   │   ├── ec2_test.py
│   │   ├── vpc_test.py
│   │   ├── dynamodb_test.py
│   │   └── terraform_wrapper.py
│   ├── go/                  # Go-based tests
│   │   ├── s3_test.go
│   │   ├── ec2_test.go
│   │   ├── dynamodb_test.go
│   │   ├── iam_test.go
│   │   ├── kms_test.go
│   │   └── vpc_test.go
│   └── README.md
├── docs/
│   ├── index.md / index.html / _navbar.md / _sidebar.md
│   ├── modules/             # Auto-synced from module READMEs
│   ├── scripts/
│   ├── environments/
│   └── test/
├── go.mod / go.sum
└── README.md
```

---

## 🚀 API Gateway → Lambda → DynamoDB Setup

The project includes a simulated API Gateway → Lambda → DynamoDB setup that demonstrates a complete serverless application flow:

### Components
- **API Gateway**: REST endpoints at `/api`
- **Lambda Function**: Python-based handler for GET and POST requests
- **DynamoDB**: Data storage with automatic table creation

### Features
- GET /api - Lists all items in the DynamoDB table
- POST /api - Creates new items (requires 'id' field)
- Automatic IAM role creation for Lambda-DynamoDB access
- Environment-specific configurations (develop/nonprod)

### Deployment Steps
1. Create Lambda deployment package:
   ```powershell
   cd modules/lambda
   .\build.ps1  # Windows
   # or
   ./build.sh   # Unix/Linux
   ```

2. Deploy the environment:
   ```powershell
   .\scripts\apply_env.ps1 -env develop
   ```

3. Test the API:
   ```bash
   # List items
   curl http://localhost:4566/restapis/<api-id>/dev/_user_request_/api

   # Create item
   curl -X POST http://localhost:4566/restapis/<api-id>/dev/_user_request_/api \
     -H "Content-Type: application/json" \
     -d '{"id": "123", "name": "Test Item"}'
   ```

> Note: Replace `<api-id>` with the actual API Gateway ID from Terraform outputs.

### Configuration
The setup is enabled by default in both develop and nonprod environments. Configuration can be found in:
- `environments/develop.tfvars` and `environments/nonprod.tfvars`
- `modules/lambda/README.md` for Lambda function details
- `modules/api_gw/README.md` for API Gateway configuration

---

## 🔐 Security Considerations & Secret Scrubbing

All secrets (including fake keys used for LocalStack) have been scrubbed from Git history.  
Credentials are now only stored in uncommitted `*.auto.tfvars` files excluded by `.gitignore`.

---

## Development Philosophy (MVP Phase)

- All work is performed directly inside `cloudsimulation_localstack/`
- Full environment destruction is acceptable during MVP
- No clone-testing structure (`cloudlab-test/`) until infrastructure states become valuable to preserve
- A future version will add sandbox testing if needed

## 📦 Module Versioning

This project uses semantic versioning (MAJOR.MINOR.PATCH) for all modules. During the MVP phase, all modules are versioned below 1.0.0 to indicate they are still in development.

### Versioning Rules
- **MAJOR version (x.0.0)**: Breaking changes that require manual intervention
- **MINOR version (0.x.0)**: New features that maintain backward compatibility
- **PATCH version (0.0.x)**: Bug fixes and minor improvements

### Current Module Versions
All modules are currently at version 0.1.0, indicating:
- Initial MVP release
- Basic functionality implemented
- Breaking changes may occur
- Not yet production-ready

### Module Version Files
Each module contains a `version.tf` file that specifies:
- Required Terraform version
- Required provider versions
- Module version constraints

Example:
```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## ⚙️ Register a Mock AMI (for EC2 module testing)
```powershell
.\scripts\register_mock_ami.ps1 -Env develop
```

- Mocks an AMI in LocalStack and updates `develop.auto.tfvars`
- Required for EC2 module to pass
- Used in CI for Terratest


## 🚀 Deploy a Local Environment

| Script | Description |
|--------|-------------|
| `run_localstack_env.ps1` | Starts LocalStack container with correct settings for a given environment. |

Example:
```powershell
.\scripts\run_localstack_env.ps1 -env develop
```

To manually cleanup the LocalStack container:
```bash
docker rm -f localstack-develop
```

Before applying terraform IaC, make sure you've run:

```powershell
.\scripts\register_mock_ami.ps1 -Env develop    # or -Env nonprod
```

This ensures a mock AMI is available for EC2 provisioning.

Then run:

```powershell
.\scripts\apply_env.ps1 -env develop     # or -env nonprod
```

This will:
- Load shared and secret `.tfvars` files
- Initialize and plan Terraform using `environments/main.tf`
- Conditionally load EC2, IAM, KMS, VPC modules based on flags
- Prompt for confirmation before applying

## 🧪 Running Tests

### Go Tests
```bash
cd test/go
go test ./... -v
```

### Python Tests
The Python tests use a custom Terraform wrapper and pytest framework to validate infrastructure modules.

#### Setup
```bash
# Install dependencies
python -m pip install pytest

# Run all Python tests
cd test/python
python -m pytest -v

# Run specific test
python -m pytest iam_test.py -v
```

#### Python Test Structure
- Each test module (e.g., `iam_test.py`) follows a consistent pattern:
  1. Configures Terraform options with environment variables
  2. Initializes and applies the Terraform configuration
  3. Validates outputs and resource properties
  4. Cleans up resources after testing

#### Terraform Wrapper
The `terraform_wrapper.py` provides a Python interface to Terraform operations:
- Handles Terraform initialization, apply, and destroy operations
- Manages environment variables and Terraform variables
- Provides output parsing and validation
- Ensures proper cleanup of resources

Example usage:
```python
from terraform_wrapper import Terraform

tf = Terraform(
    terraform_dir='../modules/iam',
    vars={'environment_name': 'test'},
    env_vars={
        'AWS_ACCESS_KEY_ID': 'test',
        'AWS_SECRET_ACCESS_KEY': 'test',
        'AWS_REGION': 'us-east-1'
    }
)

try:
    tf.init()
    tf.apply()
    output = tf.output('example_output')
finally:
    tf.destroy()
```

### Running All Tests via CI
`act -W .github/workflows/act-test.yml`
Simulates GitHub Actions pipeline:
- Runs `terraform fmt`, `validate`
- Registers AMI and tests EC2 flows
- Executes both Go and Python tests
- Validates all module-level expectations

#### Test Coverage
| Test Type | Module Coverage |
|-----------|-----------------|
| Go Tests  | All modules     |
| Python    | All modules     |

Both test suites validate:
- Resource creation and configuration
- Output values
- Resource properties
- Cleanup operations

## 🔐 Local Secrets Pattern

All secrets are loaded from `.auto.tfvars` files like:

```hcl
localstack_api_key = "your-localstack-key"
access_key         = "FAKEKEY"
secret_key         = "FAKESECRET"
```

**Never committed.**

Create your copy using:

```bash
cp environments/example.auto.tfvars.template environments/develop.auto.tfvars
```

```powershell
Copy-Item "environments\example.auto.tfvars.template" "environments\develop.auto.tfvars"
```

## Visual model:

```
 develop.tfvars
  └── (no secrets)
       ↓
 develop.auto.tfvars
  └── (local-only secrets)
       ↓
 main.tf → uses both
       ↓
 terraform apply → LocalStack
```

```
┌────────────────────────────────────┐
│  develop.tfvars                    │
│  - static inputs (AMI, flags)      │
│  - NO credentials                  │
└──────────────┬─────────────────────┘
               │
┌──────────────▼─────────────────────┐
│  develop.auto.tfvars               │
│  - local dummy secrets & ids       │
│  - not checked into Git            │
└──────────────┬─────────────────────┘
               │
        ┌──────▼──────┐
        │  main.tf    │ → Loads both files
        └─────────────┘
               │
     ┌─────────▼─────────┐
     │ LocalStack Apply  │ → Creates VPC, IAM, EC2, etc.
     └───────────────────┘
```

## 🧼 Cleanup Scripts

| Script                    | Description                                                           | Restarts Docker |
|---------------------------|-----------------------------------------------------------------------|-----------------|
| `reset_localstack.ps1`    | Stops container, removes volume, restarts LocalStack                  | ✅ Yes          |
| `clean-reset.ps1`         | Destroys all Terraform + LocalStack resources                         | ❌ No           |
| `bootstrap_dev_env.ps1`   | One-liner: reset develop, apply, launch Docsify                       | ✅ Yes          |


See [scripts/README.md](scripts/README.md) for more automation details.

---

## 🧪 Manual Terraform Flow

```bash
cd environments
terraform init
terraform plan -var-file="develop.tfvars" -var-file="develop.auto.tfvars"
terraform apply -var-file="develop.tfvars" -var-file="develop.auto.tfvars"
```

---

## 🔧 LocalStack Notes

- Port `4566`: LocalStack API gateway
- Port `31566`, `31567`: LocalStack UI per env
- Port conflicts must be resolved manually
- `LS_PLATFORM_MULTI_ACCOUNT=true` is enabled (separates `develop`, `nonprod`)

---

## ✨ Future Enhancements

- [ ] Enforce `locals`-based tagging in all modules
- [ ] Linux/macOS parity via `apply_env.sh`
- [ ] Simulated `prod` env
- [ ] Module path-based CI triggers
- [ ] Add `terraform-docs` auto-gen
- [ ] Sandbox testing folder (longer term state preservation)
- [ ] Preview/validate all Markdown for Docsify sync
- [ ] Integration with AI dev tools (Cursor, Devin, etc.)

## 📦 Requirements

- Terraform CLI v1.5+
- LocalStack Pro
- PowerShell (Windows) or Bash (Linux/macOS)
- Go 1.20+ (for Terratest)
- Python 3.12+ (for Python tests)
  - pytest>=7.0.0
- GitHub Actions OR [`act`](https://github.com/nektos/act)

## ⚠️ Known Issues

- LocalStack UI does not visually isolate environments
- Some AWS services (e.g. `aws_s3_bucket_v2`) may need fallback to older resources
- Port conflicts across containers need manual cleanup
- Terratest assumes Go is locally installed
- Python tests require LocalStack to be running on port 4566

## 🔧 Troubleshooting

### Python Tests
1. Ensure LocalStack is running:
   ```bash
   docker ps | grep localstack
   ```

2. Check Python dependencies:
   ```bash
   pip list | grep pytest
   ```

3. Verify environment variables:
   ```bash
   echo $AWS_ACCESS_KEY_ID
   echo $AWS_SECRET_ACCESS_KEY
   ```

4. Clean test artifacts:
   ```bash
   rm -rf .terraform/
   rm -f terraform.tfstate*
   ```

---
