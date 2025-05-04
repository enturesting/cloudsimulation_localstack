# 🛠️ Scripts Directory

This folder contains helper scripts for managing the LocalStack + Terraform development environment and Docsify documentation.

---

## 🔄 Environment Management

| Script                          | Description                                                                 |
|----------------------------------|-----------------------------------------------------------------------------|
| `apply_env.ps1`                 | Applies the specified Terraform environment (`develop`, `nonprod`, `feature`). |
| `reset_localstack.ps1`          | Fully resets LocalStack and reinitializes Terraform state with per-env ports. |
| `bootstrap_dev_env.ps1`         | One-liner to reset LocalStack, apply `develop`, and launch Docsify UI.      |
| `clean-reset.ps1`               | Cleans Terraform + LocalStack resources for one env (S3, EC2, IAM, etc.).   |
| `clean-all-tfstate.ps1`         | Recursively removes `.terraform/`, `.tfstate`, and `.tfstate.backup` files across the repo. |
| `run_localstack_env.ps1`        | Starts LocalStack container with correct settings for a given environment.  |
| `status_localstack_envs.ps1`    | Shows which LocalStack containers are running and their bound ports.        |
| `purge_mock_amis.ps1`           | Removes any previously registered mock AMIs from `.auto.tfvars` files.      |

---

## 🌐 Docsify and Documentation

| Script                          | Description                                                                 |
|----------------------------------|-----------------------------------------------------------------------------|
| `launch_localstack_docs.ps1`     | Starts LocalStack and launches the Docsify UI in the browser.              |
| `sync_all_docsify_readmes.ps1`  | Syncs module and top-level `README.md` files into `/docs/` for GitHub Pages. |
| `validate-metadata.ps1`         | Validates all `metadata.json` files for modules.                            |
| `ci_docs_validate.ps1`          | CI check to ensure all modules have long-form Docsify `content.md` files.  |

---

## 🐚 Other Scripts

| Script                          | Description                                                                 |
|----------------------------------|-----------------------------------------------------------------------------|
| `register_mock_ami.ps1`         | PowerShell script to register a mock EC2 AMI with LocalStack.              |
| `register_mock_ami.sh`          | Bash version of the mock AMI registration script.                          |
| `rename-dev-to-develop.ps1`     | Bulk renames `dev` references to `develop` in all config files.            |
| `visualize_aws_tf_env.ps1`      | Visualizes current Terraform AWS environment via CLI tools (e.g. Graphviz).|
| `lint-terraform.ps1`            | Runs Terraform linting and validation checks across the codebase.          |
| `bump_module_version.ps1`       | Copies a module version directory to a new version and auto-updates version numbers. |

---

## 🔢 Module Version Bumping

`bump_module_version.ps1` helps automate semantic versioning for all modules.

**Usage:**
```powershell
cd scripts
./bump_module_version.ps1 -FromVersion v0.1.0 -ToVersion v0.2.0
```

**Parameters:**
- `-FromVersion` (default: v0.1.0): The version to copy from
- `-ToVersion` (required): The new version to create (e.g., v0.2.0)
- `-Module` (optional): Only bump a single module (e.g., lambda, iam, etc)

**What it does:**
- Copies the specified version directory for each module to the new version
- Updates version numbers in `README.md`, `main.tf`, and `version.tf` inside the new version directory
- Prints a help message if usage is incorrect

**Example:**
```powershell
./bump_module_version.ps1 -FromVersion v0.1.0 -ToVersion v0.2.0 -Module lambda
```
This will only bump the `lambda` module from v0.1.0 to v0.2.0 and update version numbers in the new directory.
