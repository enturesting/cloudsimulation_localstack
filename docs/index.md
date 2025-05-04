# 🛠️ LocalStack Terraform Module Registry

> **Announcement (v0.1.0):**
>
> This is the first stable MVP version of the LocalStack Terraform Demo Lab, now using semantic versioning for all modules! Docsify and infrastructure build successfully locally. Use the `/scripts/bump_module_version.ps1` script to create new module versions as you iterate. See the main README for more details.

Welcome to the module registry for the **LocalStack Terraform Demo Lab**.

This project simulates a multi-environment AWS infrastructure (`develop`, `nonprod`) using:

- **Terraform** with reusable, modular infrastructure components
- **LocalStack Pro** to emulate AWS APIs for EC2, S3, DynamoDB, IAM, KMS, and VPC
- **CI/CD pipelines** with GitHub Actions + local `act` support
- **Terratest (Go)** for automated infrastructure testing
- **Docsify** for a lightweight local module registry UI
- **Custom PowerShell & Bash scripts** for provisioning, testing, and clean reset flows

> Use the sidebar to browse Terraform modules, test definitions, CI workflows, and scripts.

---

## 📚 Registry Highlights

- Full module breakdowns with `inputs`, `outputs`, and usage
- CI pipelines for formatting, validation, Terratest execution
- Environment support: `develop`, `nonprod`, and (future) `prod`
- Cross-platform automation scripts (PowerShell + Bash)
- Future support for `terraform-docs`, remote backends, tagging standards

---

## 🧪 Testing Support

- [x] EC2 AMI mock registration
- [x] Module conditionals + toggles
- [x] Matrix-based environment test runs via `act`
- [x] Go-based Terratest files (`*_test.go`)

---

## 🚀 Getting Started

To spin up the registry locally:

```bash
npm install -g docsify-cli
docsify serve docs
```

To deploy infrastructure:

```powershell
.\scripts\apply_env.ps1 -env develop
```

---

Stay tuned as this lab continues evolving with more modules, deeper test coverage, and simulated prod environments!
