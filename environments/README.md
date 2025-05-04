# Environments Configuration

This folder contains Terraform configurations and variable files for different simulated AWS environments, powered by [LocalStack Pro](https://localstack.cloud/) and modular Terraform.

## Structure

```
environments/
├── develop.tfvars            # Default (non-sensitive) vars for develop
├── develop.auto.tfvars       # Secrets (LocalStack key, AWS dummy creds)
├── nonprod.tfvars            # Nonprod environment vars
├── nonprod.auto.tfvars       # Nonprod secrets
├── example.auto.tfvars       # Template for creating new .auto.tfvars
├── main.tf                   # Shared entrypoint for all environments
├── variables.tf              # Shared variable declarations
└── outputs.tf                # Common outputs (e.g. VPC, EC2 IPs, ARNs)
```

## Quickstart

### 1. Create a Local Secrets File

Copy the example template and customize it per environment:

```bash
cp example.auto.tfvars develop.auto.tfvars
cp example.auto.tfvars nonprod.auto.tfvars
```

Edit each file and provide the required LocalStack credentials:

```hcl
localstack_api_key = "<YOUR_LOCALSTACK_API_KEY>"
access_key         = "<DUMMY_ACCESS_KEY>"
secret_key         = "<DUMMY_SECRET_KEY>"
region             = "us-east-1"
```

> 🔒 These files are excluded from Git and used locally to simulate AWS credentials.

### 2. Prepare Lambda Deployment Package

If you're using the API Gateway → Lambda → DynamoDB setup:

1. Navigate to the Lambda module directory:
```bash
cd modules/lambda
```

2. Make the build script executable:
```bash
chmod +x build.sh
```

3. Run the build script to create the deployment package:
```bash
./build.sh
```

This will create a `lambda_function.zip` file containing the Lambda function code and its dependencies.

### 3. Initialize & Apply Terraform

Run Terraform using both `.tfvars` and `.auto.tfvars` files:

```bash
terraform init
terraform apply -var-file=develop.tfvars -var-file=develop.auto.tfvars
```

For nonprod or feature environments:

```bash
terraform apply -var-file=nonprod.tfvars -var-file=nonprod.auto.tfvars
```

## API Gateway → Lambda → DynamoDB Setup

The environment includes a simulated API Gateway → Lambda → DynamoDB setup:

- API Gateway provides REST endpoints at `/api`
- Lambda function handles GET and POST requests
- DynamoDB stores the data

### Available Endpoints

- GET /api - Lists all items in the DynamoDB table
- POST /api - Creates a new item in the DynamoDB table (requires 'id' field in request body)

### Example Usage

```bash
# List all items
curl http://localhost:4566/restapis/<api-id>/dev/_user_request_/api

# Create a new item
curl -X POST http://localhost:4566/restapis/<api-id>/dev/_user_request_/api \
  -H "Content-Type: application/json" \
  -d '{"id": "123", "name": "Test Item"}'
```

Replace `<api-id>` with the actual API Gateway ID from the Terraform outputs.

## Usage Tips

- Use scripts like `apply_env.ps1` and `reset_localstack.ps1` to automate per-environment provisioning and teardown.
- All environments share the same Terraform logic but are isolated via input variable files and separate LocalStack containers (with different ports and volumes).
- Define conditional resources (like EC2, KMS, VPC) using flags inside `.tfvars` for a modular rollout.
- The API Gateway and Lambda setup is enabled by default in both develop and nonprod environments.

## Best Practices

- ✅ Keep `*.tfvars` checked into Git (non-sensitive)
- 🔒 Never commit `*.auto.tfvars` (they contain secrets)
- 🧹 Use cleanup scripts (`clean-reset.ps1`, `purge_mock_amis.ps1`) before switching environments
- 🔄 Use `register_mock_ami.ps1` after a reset if EC2 is enabled
- 🔄 Rebuild the Lambda deployment package if you modify the Lambda function code
