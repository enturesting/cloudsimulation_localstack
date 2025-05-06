# LLM Router Module

This Terraform module sets up an LLM Router infrastructure with the following components:
- Lambda function for handling LLM requests
- API Gateway for exposing the Lambda function
- DynamoDB table for storing conversation history

## Module Structure
```
modules/llm_router/v0.1.0/
├── lambda/                 # Lambda function code
│   ├── index.js           # Main Lambda handler
│   └── package.json       # Node.js dependencies
├── main.tf                # Main module configuration
├── variables.tf           # Input variables
├── outputs.tf            # Module outputs
└── README.md             # This file
```

## Usage

```hcl
module "llm_router" {
  source = "path/to/modules/llm_router/v0.1.0"

  environment     = "develop"
  name_prefix     = "my-llm-router"
  lambda_zip_path = "path/to/lambda.zip"
  
  tags = {
    Environment = "develop"
    Project     = "LLM-Router"
  }
}
```

## Requirements

- Terraform >= 1.0.0
- AWS provider configured
- Node.js and npm (for Lambda function development)
- LocalStack (for local development)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., develop, nonprod, prod) | `string` | n/a | yes |
| name_prefix | Prefix to be used for all resource names | `string` | `"llm-router"` | no |
| lambda_zip_path | Path to the Lambda function zip file | `string` | n/a | yes |
| tags | Tags to be applied to all resources | `map(string)` | `{}` | no |
| region | AWS region | `string` | `"us-east-1"` | no |
| localstack_endpoint | LocalStack endpoint URL (for local development) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_endpoint | API Gateway endpoint URL |
| lambda_function_name | Name of the Lambda function |
| lambda_function_arn | ARN of the Lambda function |
| dynamodb_table_name | Name of the DynamoDB table |
| dynamodb_table_arn | ARN of the DynamoDB table |

## Lambda Function

The Lambda function is included in the `lambda/` directory of this module. It handles:
- Processing incoming LLM requests
- Storing conversations in DynamoDB
- Returning responses with proper CORS headers

### Building the Lambda Function

To build the Lambda function:

1. Navigate to the Lambda directory:
```bash
cd modules/llm_router/v0.1.0/lambda
```

2. Install dependencies:
```bash
npm install
```

3. Use the provided script to create the zip file:
```powershell
./scripts/prepare_lambda.ps1
```

## Local Development with LocalStack

### Prerequisites
1. Docker installed
2. LocalStack running locally
3. AWS CLI configured with dummy credentials for LocalStack

### Setup Steps

1. Start LocalStack:
```bash
docker-compose up -d
```

2. Create a `develop.auto.tfvars` file in your environment directory with LocalStack credentials:
```hcl
access_key = "test"
secret_key = "test"
account_id = "000000000000"
```

3. Deploy using the provided PowerShell script:
```powershell
./scripts/apply_env.ps1 -env develop -path environments/llm_router
```

4. Test the deployment:
```bash
# Get the API endpoint
terraform output api_endpoint

# Test the API
curl -X POST -H "Content-Type: application/json" \
  -d '{"user_id": "test", "query": "Hello"}' \
  http://localhost:4566/execute-api/your-api-id/develop/chat
```

### Troubleshooting

1. If you get permission errors, ensure your LocalStack is running and accessible:
```bash
curl http://localhost:4566/health
```

2. To view LocalStack logs:
```bash
docker-compose logs -f
```

3. To reset LocalStack state:
```bash
docker-compose down -v
docker-compose up -d
```

## Notes

- The Lambda function requires Node.js 18.x runtime
- The DynamoDB table uses PAY_PER_REQUEST billing mode
- API Gateway is configured with CORS support
- The Lambda function has permissions to access DynamoDB and CloudWatch Logs 