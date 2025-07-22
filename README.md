# 🛠️ LocalStack Terraform Learning Lab

> **Current Version (v1.0.0):**
> 
> Complete production-ready multi-environment Terraform infrastructure with LocalStack Pro/Community support, comprehensive testing, security scanning, and automated documentation generation. Perfect for learning Terraform with real AWS service emulation.

🌐 [View Module Registry Docs](https://enturesting.github.io/cloudsimulation_localstack/)

## 🎯 What You'll Learn

This comprehensive Terraform lab teaches modern infrastructure practices through hands-on experience:

- **Multi-Environment Management**: Separate `develop` and `nonprod` environments with full isolation
- **Modular Infrastructure**: Reusable, versioned modules following best practices
- **Infrastructure Testing**: Both Python and Go-based testing with `terraform_wrapper` and Terratest
- **Security Scanning**: Automated security analysis with pattern-based detection
- **Documentation Automation**: Auto-generated module docs with terraform-docs
- **CI/CD Integration**: GitHub Actions workflows and local testing with `act`
- **Real AWS Emulation**: LocalStack Pro/Community for authentic AWS experience

[![Terraform](https://img.shields.io/badge/IaC-Terraform-blue)](https://www.terraform.io/)
[![LocalStack](https://img.shields.io/badge/Simulated-AWS-lightgrey)](https://localstack.cloud)
[![CI](https://github.com/enturesting/cloudsimulation_localstack/actions/workflows/terraform-test.yml/badge.svg)](https://github.com/enturesting/cloudsimulation_localstack/actions)

---

## 🚀 Quick Start

### Prerequisites

Choose your LocalStack version:

**Option A: LocalStack Community (Free)**
```bash
# No API key required
docker pull localstack/localstack
```

**Option B: LocalStack Pro (Recommended)**
```bash
# Sign up at https://localstack.cloud for Pro features:
# - Multi-account support (environment isolation)
# - Advanced AWS services
# - Web UI integration
export LOCALSTACK_API_KEY="your-api-key-here"
```

**Required Tools:**
- Terraform CLI v1.5+
- Docker Desktop or Rancher Desktop
- PowerShell (Windows) or Bash (Linux/macOS)
- Python 3.8+ with pip (for testing and security scanning)

### 1. Clone and Setup

```bash
git clone <your-repo>
cd cloudsimulation_localstack

# Create your local configuration
cp environments/example.auto.tfvars.template environments/develop.auto.tfvars
cp environments/example.auto.tfvars.template environments/nonprod.auto.tfvars
```

### 2. Configure Your Environment

Edit `environments/develop.auto.tfvars`:
```hcl
# For LocalStack Pro users
localstack_api_key = "your-localstack-pro-key"

# For LocalStack Community users, comment out the line above

# These are safe demo credentials for LocalStack
access_key = "test-access-dev"
secret_key = "test-secret-dev"
ami_id = "ami-024f768332f0"  # Mock AMI ID
bucket_name = "dev-terraform-test-bucket"
account_id = "111111111111"  # Mock 12-digit account ID
```

### 3. Deploy Your First Environment

**Option A: PowerShell (Windows)**
```powershell
# Start LocalStack and deploy develop environment
.\scripts\run_localstack_env.ps1 -env develop
.\scripts\apply_env.ps1 -env develop
```

**Option B: Bash (Linux/macOS)**
```bash
# Start LocalStack and deploy develop environment
./scripts/bash_mvp/run_localstack_env.sh develop
./scripts/bash_mvp/apply_env.sh develop
```

### 4. Access Your Infrastructure

- **LocalStack Web UI**: http://localhost:31566 (develop) or http://localhost:32566 (nonprod)
- **LocalStack Cloud Platform**: https://app.localstack.cloud/instances
- **API Gateway Endpoint**: Check Terraform outputs for your specific URL

---

## 🏗️ Architecture Overview

### Infrastructure Components

**Core Services Deployed:**
- **VPC**: Complete networking with public/private subnets, internet gateway, security groups
- **DynamoDB**: NoSQL database with encryption and backup configuration  
- **S3**: Object storage with versioning, encryption, and public access blocking
- **EC2**: Virtual machines with proper networking and security
- **Lambda**: Serverless functions with IAM roles and policies
- **API Gateway**: REST APIs with Lambda integration
- **IAM**: Roles, policies, and permissions following least privilege
- **KMS**: Encryption keys for data protection (nonprod environment)

### Multi-Environment Setup

| Environment | LocalStack Port | Web UI Port | Purpose |
|-------------|----------------|-------------|---------|
| **develop** | 4566 | 31566 | Development and testing |
| **nonprod** | 4567 | 32566 | Pre-production validation |

Each environment has completely isolated resources and state management.

---

## 📁 Project Structure

```bash
cloudsimulation_localstack/
├── 📦 modules/                    # Reusable Terraform modules
│   ├── api_gateway/v0.2.0/       # REST API Gateway with examples
│   ├── dynamodb/v0.2.0/          # NoSQL database with encryption
│   ├── ec2/v0.2.0/               # Virtual machines with networking
│   ├── iam/v0.2.0/               # Roles and policies
│   ├── kms/v0.2.0/               # Encryption keys
│   ├── lambda/v0.2.0/            # Serverless functions
│   ├── s3/v0.2.0/                # Object storage with security
│   └── vpc/v0.2.0/               # Networking infrastructure
├── 🌍 environments/              # Environment-specific configurations
│   ├── develop.tfvars            # Development settings
│   ├── nonprod.tfvars            # Non-production settings
│   ├── develop.auto.tfvars       # Local secrets (not in Git)
│   ├── nonprod.auto.tfvars       # Local secrets (not in Git)
│   ├── main.tf                   # Main infrastructure definition
│   ├── variables.tf              # Input variables
│   └── outputs.tf                # Output values
├── 🧪 test/                      # Infrastructure testing
│   ├── python/                   # Python-based tests with pytest
│   │   ├── terraform_wrapper.py  # Enhanced Terraform automation
│   │   └── *_test.py             # Individual module tests
│   └── go/                       # Go-based tests with Terratest
│       └── *_test.go             # Terratest validation
├── 🔧 scripts/                   # Automation and utilities
│   ├── apply_env.ps1             # Deploy environment (Windows)
│   ├── run_localstack_env.ps1    # Start LocalStack (Windows)
│   ├── security_scan.ps1         # Security analysis
│   ├── generate_docs.ps1         # Auto-generate documentation
│   └── bash_mvp/                 # Cross-platform Bash versions
├── 🛡️ backend/                   # Remote state management
│   └── backend.tf                # S3 + DynamoDB backend
├── 📚 docs/                      # Auto-generated documentation
│   └── modules/                  # Module registry documentation
└── 📋 examples/                  # Real-world usage examples
    ├── static_website.tf         # S3-hosted website
    ├── data_lake.tf              # Analytics infrastructure  
    ├── api_microservice.tf       # Serverless API
    └── multi_tier_app.tf         # Complex application stack
```

---

## 🚀 Deployment Guide

### Method 1: Automated Scripts (Recommended)

**Deploy Develop Environment:**
```powershell
# Windows
.\scripts\run_localstack_env.ps1 -env develop
.\scripts\apply_env.ps1 -env develop
```

```bash
# Linux/macOS
./scripts/bash_mvp/run_localstack_env.sh develop  
./scripts/bash_mvp/apply_env.sh develop
```

**Deploy Nonprod Environment:**
```powershell
# Windows  
.\scripts\run_localstack_env.ps1 -env nonprod
.\scripts\apply_env.ps1 -env nonprod
```

```bash
# Linux/macOS
./scripts/bash_mvp/run_localstack_env.sh nonprod
./scripts/bash_mvp/apply_env.sh nonprod
```

### Method 2: Manual Terraform Commands

```bash
# Start LocalStack container first
docker run -d --name localstack-develop \
  -p "4566:4566" -p "31566:31566" \
  -e LOCALSTACK_AUTH_TOKEN="your-api-key" \
  -v "localstack-vol-develop:/var/lib/localstack" \
  localstack/localstack-pro

# Deploy infrastructure
cd environments
terraform init
terraform workspace new develop  # or: terraform workspace select develop
terraform plan -var-file="develop.tfvars" -var-file="develop.auto.tfvars"
terraform apply -var-file="develop.tfvars" -var-file="develop.auto.tfvars"
```

### Environment Configuration

**Develop Environment (`develop.tfvars`):**
- Lightweight configuration for development
- KMS encryption disabled for faster iteration  
- Standard monitoring and logging
- Test data and dummy resources

**Nonprod Environment (`nonprod.tfvars`):**
- Production-like configuration
- KMS encryption enabled for security testing
- Enhanced monitoring and alerting
- Realistic data volumes and configurations

---

## 🧪 Testing Infrastructure

### Python Tests with Enhanced Wrapper

The project includes a sophisticated Python testing framework:

```bash
# Install dependencies
cd test/python
pip install -r requirements.txt

# Run all tests
python -m pytest -v

# Run specific module test
python -m pytest dynamodb_test.py -v

# Run with detailed output
python -m pytest -v -s --tb=short
```

**Key Features:**
- **Isolated Workspaces**: Each test runs in its own Terraform workspace
- **Automatic Cleanup**: Resources are destroyed after each test
- **Context Managers**: Proper resource lifecycle management
- **Cross-Platform**: Works on Windows, Linux, and macOS

### Go Tests with Terratest

```bash
cd test/go
go mod tidy
go test ./... -v -timeout 30m
```

### Test Coverage

| Module | Python Tests | Go Tests | Features Tested |
|--------|-------------|----------|-----------------|
| **VPC** | ✅ | ✅ | Subnets, Security Groups, IGW |
| **DynamoDB** | ✅ | ✅ | Tables, Encryption, Backup |
| **S3** | ✅ | ✅ | Buckets, Versioning, Security |
| **Lambda** | ✅ | ✅ | Functions, IAM, Integration |
| **API Gateway** | ✅ | ✅ | REST APIs, Methods, Deployment |
| **IAM** | ✅ | ✅ | Roles, Policies, Attachments |
| **EC2** | ✅ | ✅ | Instances, Networking, Security |
| **KMS** | ✅ | ✅ | Keys, Policies, Encryption |

---

## 🔄 Automated Testing & CI/CD

### GitHub Actions Integration

The project includes comprehensive automated testing workflows that validate infrastructure, documentation, and code quality:

```bash
# View workflow status and history
# Visit: https://github.com/your-repo/actions
```

**Available Workflows**:
- **🏃‍♂️ ACT-Compatible Testing** (`act-test.yml`): Lightweight validation for local development
- **🚀 Full CI/CD Pipeline** (`terraform-test.yml`): Comprehensive multi-environment testing

**Testing Phases**:
1. **Environment Setup**: Go, Python, Terraform, and LocalStack initialization
2. **Infrastructure Validation**: Terraform hygiene, module syntax validation
3. **Documentation Verification**: README.md completeness across all modules
4. **Multi-Language Testing**: Both Go (Terratest) and Python test suites
5. **Security & Quality**: Automated lambda packaging and AMI registration testing

### Local Testing with Act

```bash
# Install act (GitHub Actions local runner)
brew install act  # macOS

# Run lightweight testing workflow locally
act -W .github/workflows/act-test.yml

# Run with LocalStack Pro token
act -W .github/workflows/act-test.yml -s LOCALSTACK_AUTH_TOKEN="your-token"
```

**📋 For detailed CI/CD documentation, see [.github/workflows/README.md](.github/workflows/README.md)**

---

## 🛡️ Security Scanning

### Automated Security Analysis

The project includes comprehensive security scanning to identify common infrastructure security issues:

```powershell
# Run security scan on current infrastructure
.\scripts\security_scan.ps1

# Scan specific environment
.\scripts\security_scan.ps1 -Environment develop
```

```bash
# Linux/macOS
./scripts/bash_mvp/security_scan.sh
```

### Security Checks Performed

**Secrets Detection:**
- Hardcoded API keys and passwords
- AWS access keys in code
- Database connection strings
- Private keys and certificates

**AWS Security Best Practices:**
- S3 bucket public access policies
- IAM wildcard permissions (`*`)
- Unencrypted storage resources
- Overly permissive security groups
- Missing resource tagging

**Infrastructure Security:**
- Public IP assignments
- Open security group rules (0.0.0.0/0)
- Unencrypted data stores
- Missing backup configurations

### Security Report Formats

The scanner generates reports in multiple formats:
- **JSON**: `scripts/security_reports/security_report.json`
- **HTML**: `scripts/security_reports/security_report.html`  
- **SARIF**: `scripts/security_reports/security_report.sarif` (GitHub integration)

### Example Security Findings

```json
{
  "severity": "HIGH",
  "rule": "hardcoded_secret",
  "message": "Potential hardcoded secret found",
  "file": "environments/develop.tfvars",
  "line": 15,
  "match": "password = \"hardcoded123\""
}
```

---

## 📚 Documentation Generation

### Automated Module Documentation

Generate beautiful documentation for all modules:

```powershell
# Generate docs for all modules
.\scripts\generate_docs.ps1

# Generate docs for specific module
.\scripts\generate_docs.ps1 -Module dynamodb
```

This creates:
- **README.md** files with usage examples
- **Input/Output tables** with descriptions
- **Resource documentation** with links
- **Example configurations** for common use cases

### Documentation Features

- **terraform-docs** integration for automatic generation
- **Real-world examples** for each module
- **Version compatibility** matrices
- **Security considerations** for each component
- **Performance optimization** tips

---

## 🔍 Dependency Analysis

Understand your infrastructure relationships:

```powershell
# Analyze module dependencies
.\scripts\dependency_analyzer_simple.py

# Generate dependency visualization
.\scripts\visualize_dependencies.ps1
```

Outputs:
- **JSON reports**: Module relationships and resource dependencies
- **Dependency graphs**: Visual representation of infrastructure
- **Impact analysis**: Understanding change propagation

---

## 🎓 Learning Modules & Examples

### Real-World Examples

The `examples/` directory contains practical Terraform configurations:

**1. Static Website (`examples/static_website.tf`)**
```hcl
# S3-hosted static website with CloudFront-like setup
module "static_website" {
  source = "../modules/s3/v0.2.0"
  
  bucket_name = "my-static-website"
  enable_website = true
  website_index = "index.html"
  website_error = "error.html"
}
```

**2. Data Lake (`examples/data_lake.tf`)**
```hcl
# Analytics infrastructure with S3 and DynamoDB
module "data_lake" {
  source = "../modules/s3/v0.2.0"
  
  bucket_name = "analytics-data-lake"
  enable_versioning = true
  enable_lifecycle = true
}
```

**3. API Microservice (`examples/api_microservice.tf`)**
```hcl
# Complete serverless API with Lambda and API Gateway
module "api" {
  source = "../modules/api_gateway/v0.2.0"
  
  api_name = "user-service"
  stage_name = "prod"
}
```

### Progressive Learning Path

**Beginner (Modules 1-3):**
1. **VPC**: Learn networking fundamentals
2. **S3**: Understand object storage and security
3. **IAM**: Master permissions and policies

**Intermediate (Modules 4-6):**
4. **Lambda**: Serverless computing concepts
5. **DynamoDB**: NoSQL database design
6. **API Gateway**: REST API management

**Advanced (Modules 7-8):**
7. **EC2**: Virtual machine management
8. **KMS**: Encryption and key management

---

## 🌐 LocalStack Integration

### LocalStack Pro Features (Recommended)

- **Multi-Account Support**: True environment isolation
- **Advanced Services**: More AWS services available
- **Web UI**: Rich interface for resource management
- **Cloud Platform**: Remote monitoring and management

### LocalStack Community Features

- **Core Services**: S3, DynamoDB, Lambda, API Gateway, etc.
- **Local Development**: Perfect for learning and testing
- **No Cost**: Free for educational use
- **Easy Setup**: Docker-based deployment

### LocalStack Configuration

**Pro Configuration:**
```bash
export LOCALSTACK_AUTH_TOKEN="your-pro-key"
export LS_PLATFORM_MULTI_ACCOUNT=true
```

**Community Configuration:**
```bash
# No authentication required
export LOCALSTACK_HOST=localhost
```

### Accessing Your Infrastructure

**LocalStack Web Interface:**
- **Develop**: http://localhost:31566
- **Nonprod**: http://localhost:32566

**LocalStack Cloud Platform (Pro only):**
- https://app.localstack.cloud/instances
- Update bookmarks to use: `http://localhost:4566` and `http://localhost:4567`

**Direct API Access:**
```bash
# List S3 buckets
aws s3 ls --endpoint-url=http://localhost:4566

# Query DynamoDB
aws dynamodb list-tables --endpoint-url=http://localhost:4566
```

---

## 🧹 Environment Management

### Cleanup Commands

**Reset Everything:**
```powershell
# Destroy infrastructure and restart LocalStack
.\scripts\reset_localstack.ps1 -env develop

# Clean Terraform state without restarting LocalStack  
.\scripts\clean-reset.ps1 -env develop
```

**One-Command Bootstrap:**
```powershell
# Reset, deploy, and launch documentation
.\scripts\bootstrap_dev_env.ps1
```

### Container Management

**Check Running Containers:**
```bash
docker ps --filter "name=localstack" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Manual Container Operations:**
```bash
# Stop environments
docker stop localstack-develop localstack-nonprod

# Remove containers
docker rm localstack-develop localstack-nonprod

# Clean volumes
docker volume prune
```

---

## 🔧 Troubleshooting

### Common Issues

**1. LocalStack Not Starting**
```bash
# Check if ports are in use
netstat -tlnp | grep 4566

# Clean up old containers
docker rm -f $(docker ps -aq --filter "name=localstack")
```

**2. Terraform State Issues**
```bash
# Clean local state
rm -rf .terraform/
rm -f terraform.tfstate*

# Reinitialize
terraform init
```

**3. Permission Errors**
```bash
# Verify AWS credentials for LocalStack
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_REGION=us-east-1
```

**4. Module Version Conflicts**
```bash
# Update all modules
terraform init -upgrade
```

### Getting Help

1. **Check the logs**: `docker logs localstack-develop`
2. **Verify configuration**: Review your `.auto.tfvars` files
3. **Test connectivity**: `curl http://localhost:4566/_localstack/health`
4. **Clean slate**: Run the bootstrap script for a fresh start

---

## 🚀 Advanced Features

### Remote State Management

```bash
# Set up remote state backend
cd backend
terraform init
terraform apply

# Configure environments to use remote state
# (Configuration automatically generated)
```

### CI/CD Integration

**GitHub Actions:**
```yaml
# .github/workflows/terraform-test.yml
name: Terraform Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Terraform Tests
        run: ./scripts/bash_mvp/ci_docs_validate.sh
```

**Local Testing with Act:**
```bash
# Install act (GitHub Actions simulator)
# Run local CI pipeline
act -W .github/workflows/terraform-test.yml
```

### Custom Module Development

1. **Create new module**: Copy existing module structure
2. **Add version constraints**: Update `version.tf`
3. **Write tests**: Add Python and Go tests
4. **Generate docs**: Run `generate_docs.ps1`
5. **Security scan**: Run `security_scan.ps1`

---

## 📈 Performance Optimization

### LocalStack Performance Tips

```bash
# Increase LocalStack memory limit
export LOCALSTACK_DOCKER_FLAGS="-m 2g"

# Enable persistence for faster restarts (Pro only)
export PERSISTENCE=1

# Use specific services only
export SERVICES=s3,dynamodb,lambda,apigateway
```

### Terraform Performance

```bash
# Parallel resource creation
export TF_CLI_ARGS_apply="-parallelism=10"

# Reduced refresh for large states
terraform apply -refresh=false
```

---

## 🤝 Contributing

### Development Workflow

1. **Fork and clone** the repository
2. **Create feature branch**: `git checkout -b feature/new-module`
3. **Develop and test**: Add your changes with tests
4. **Run security scan**: Ensure no security issues
5. **Generate documentation**: Update all docs
6. **Submit PR**: Include test results and documentation

### Code Standards

- **Terraform**: Follow HashiCorp style guide
- **Python**: PEP 8 compliance with black formatting
- **Go**: Standard Go formatting with `go fmt`
- **Security**: No hardcoded secrets or credentials

---

## 📋 Requirements Summary

| Component | Version | Purpose |
|-----------|---------|---------|
| **Terraform** | 1.5+ | Infrastructure provisioning |
| **Docker** | Latest | LocalStack containers |
| **Python** | 3.8+ | Testing and automation |
| **Go** | 1.19+ | Terratest integration |
| **PowerShell** | 5.1+ | Windows automation |
| **Bash** | 4.0+ | Linux/macOS automation |

### Python Dependencies
```bash
pip install pytest>=7.0.0 python-terraform>=0.10.1 boto3>=1.26.0
```

### Go Dependencies
```bash
go mod tidy  # Automatically installs Terratest dependencies
```

---

## 🎯 Learning Outcomes

After completing this lab, you'll understand:

- ✅ **Multi-environment Terraform** patterns and best practices
- ✅ **Infrastructure testing** with both Python and Go
- ✅ **Security scanning** and vulnerability management
- ✅ **Module versioning** and dependency management
- ✅ **Documentation automation** with terraform-docs
- ✅ **CI/CD integration** for infrastructure pipelines
- ✅ **LocalStack usage** for AWS service emulation
- ✅ **Real-world patterns** for production infrastructure

---

## 📞 Support & Community

- **Documentation**: Complete module registry at the docs link above
- **Issues**: Use GitHub issues for bugs and feature requests  
- **Examples**: Check the `examples/` directory for real-world usage
- **Updates**: Watch the repository for new features and modules

**Happy Infrastructure Learning!** 🚀

---

*This project is designed for educational purposes and demonstrates production-ready Terraform patterns using LocalStack for safe, local AWS development.*