# 🛠️ Terraform + LocalStack Script Utilities

This folder contains helpful PowerShell scripts to manage and visualize Terraform environments powered by LocalStack.
---

## 📁 Script Descriptions

### `apply_env.ps1`
Deploys a Terraform environment by specifying the environment name (`dev` or `nonprod`).
#### **Usage**
.\apply_env.ps1 -env dev
.\apply_env.ps1 -env nonprod

### `clean-reset.ps1`
Performs a hard reset of all local state:
Deletes Terraform state files. Wipes LocalStack data directory. Useful for full environment reboots
#### **Usage**
.\clean-reset.ps1

### `register_mock_ami.ps1`
Registers a mock AMI in LocalStack for use with EC2 testing.
This bypasses the lack of public AMI support in LocalStack by simulating an AMI registration.
✅ Make sure LocalStack is running and the AWS CLI is properly configured.
#### **Usage**
.\register_mock_ami.ps1

### `reset_localstack.ps1`
Stops and restarts the LocalStack container (e.g., if you're running it manually or via Rancher Desktop), and clears residual data.
#### **Usage**
.\reset_localstack.ps1

### `visualize_aws_tf_env.ps1`
Displays current LocalStack resources (S3, DynamoDB, IAM, EC2) for the specified environment (dev, nonprod, or all).
Useful for debugging and verifying what exists in your simulated AWS environment. Supports: dev, nonprod, or all
Resources shown: S3 buckets, DynamoDB tables, IAM roles, EC2 instances
#### **Usage**
.\visualize_aws_tf_env.ps1 -Env all

### `Prerequisites`
* Terraform installed
* AWS CLI installed and profiles set up (dev, nonprod)
* LocalStack running at http://localhost:4566
* PowerShell 5.1+ or PowerShell Core

### `💡 Tip`
Use these scripts together for a complete LocalStack + Terraform testing workflow. For example:

.\reset_localstack.ps1
.\apply_env.ps1 -env dev
.\visualize_aws_tf_env.ps1 -Env dev
