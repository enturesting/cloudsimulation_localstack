# AWS Lambda Module

## Version: 0.2.0

This module creates an AWS Lambda function with configurable parameters and optional API Gateway integration. The function is designed to interact with DynamoDB and handle HTTP requests from API Gateway.

## Prerequisites

- Python 3.9 or later
- pip package manager
- zip utility

## Deployment Package Creation

Before applying the Terraform configuration, you need to create the Lambda deployment package:

### For Windows Users:
```powershell
cd modules/lambda
.\build.ps1
```

### For Unix/Linux Users:
```bash
cd modules/lambda
chmod +x build.sh
./build.sh
```

This will:
- Create a Python virtual environment
- Install required dependencies (boto3)
- Package the Lambda function code and dependencies
- Create a `lambda_function.zip` file in the module directory

## Usage

### Default Python Configuration (Recommended)

```hcl
module "lambda" {
  source = "./modules/lambda"

  function_name    = "my-lambda-function"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
  memory_size      = 256
  dynamodb_table   = "my-dynamodb-table"

  environment_variables = {
    ENV_VAR_1 = "value1"
    ENV_VAR_2 = "value2"
  }

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }

  allow_api_gateway         = true
  api_gateway_execution_arn = aws_api_gateway_rest_api.this.execution_arn
}
```

### Alternative Node.js Configuration

If you want to use Node.js instead of Python, you'll need to:

1. Create your own deployment package
2. Provide the following configuration:

```hcl
module "lambda" {
  source = "./modules/lambda"

  filename         = "path/to/function.zip"  # Path to your Node.js deployment package
  function_name    = "my-lambda-function"
  role_arn         = aws_iam_role.lambda_role.arn  # If using external IAM role
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 30
  memory_size      = 256
  dynamodb_table   = "my-dynamodb-table"

  # ... rest of the configuration
}
```

> Note: When using Node.js, you'll need to handle the DynamoDB integration in your own code and manage the deployment package creation process.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| function_name | Name of the Lambda function | string | n/a | yes |
| handler | Function entrypoint in your code | string | "lambda_function.lambda_handler" | no |
| runtime | Runtime environment for the Lambda function | string | "python3.9" | no |
| timeout | Amount of time your Lambda Function has to run in seconds | number | 3 | no |
| memory_size | Amount of memory in MB your Lambda Function can use at runtime | number | 128 | no |
| dynamodb_table | Name of the DynamoDB table to interact with | string | n/a | yes |
| environment_variables | Environment variables for the Lambda function | map(string) | {} | no |
| tags | Tags to apply to the Lambda function | map(string) | {} | no |
| allow_api_gateway | Whether to allow API Gateway to invoke this Lambda function | bool | true | no |
| api_gateway_execution_arn | ARN of the API Gateway execution role | string | "" | no |
| filename | Path to the function's deployment package (only needed for custom runtimes) | string | "${path.module}/lambda_function.zip" | no |
| role_arn | IAM role ARN (only needed if not using the default role) | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| function_name | The name of the Lambda function |
| function_arn | The ARN of the Lambda function |
| invoke_arn | The ARN to be used for invoking the Lambda function from API Gateway |
| role_arn | The ARN of the IAM role created for the Lambda function |
| qualified_arn | The ARN identifying your Lambda Function Version |

## Lambda Function Features

The included Lambda function (`lambda_function.py`) provides the following functionality:

- GET /api - Lists all items in the configured DynamoDB table
- POST /api - Creates a new item in the DynamoDB table (requires 'id' field in request body)

## Build Script Details

The PowerShell build script (`build.ps1`) performs the following steps:

1. Creates a Python virtual environment using Windows paths
2. Activates the virtual environment using PowerShell syntax
3. Installs boto3
4. Creates a package directory and copies the Lambda function
5. Uses Python's built-in shutil module to create the zip file
6. Cleans up temporary files 

# Lambda Module

## Versioning

This module follows semantic versioning (MAJOR.MINOR.PATCH). During the MVP phase, we're using version 0.x.x to indicate that the module is still in development and may have breaking changes.

### Available Versions

- [v0.2.0](./v0.2.0/README.md) - Initial MVP release
  - Basic Lambda function creation
  - API Gateway integration
  - DynamoDB interaction

### Versioning Rules

- **MAJOR version (x.0.0)**: Breaking changes that require manual intervention
- **MINOR version (0.x.0)**: New features that maintain backward compatibility
- **PATCH version (0.0.x)**: Bug fixes and minor improvements

### Usage

To use a specific version of this module:

```hcl
module "lambda" {
  source = "../modules/lambda/v0.2.0"  # or v0.2.0, v1.0.0, etc.
  
  # ... configuration
}
```

### Future Versions

- v0.2.0 (Planned)
  - Enhanced error handling
  - Additional runtime support
  - Improved testing

- v1.0.0 (Future Production Release)
  - Stable API
  - Production-ready features
  - Comprehensive documentation 

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_api_gateway"></a> [allow\_api\_gateway](#input\_allow\_api\_gateway) | Whether to allow API Gateway to invoke this Lambda function | `bool` | `true` | no |
| <a name="input_api_gateway_execution_arn"></a> [api\_gateway\_execution\_arn](#input\_api\_gateway\_execution\_arn) | ARN of the API Gateway execution role | `string` | `""` | no |
| <a name="input_dynamodb_table"></a> [dynamodb\_table](#input\_dynamodb\_table) | Name of the DynamoDB table to interact with | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the Lambda function | `map(string)` | `{}` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | Path to the function's deployment package within the local filesystem | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Lambda function | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in your code | `string` | n/a | yes |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB your Lambda Function can use at runtime | `number` | `128` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | IAM role ARN attached to the Lambda Function | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime environment for the Lambda function | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the Lambda function | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Amount of time your Lambda Function has to run in seconds | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | The ARN of the Lambda function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | The name of the Lambda function |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | The ARN to be used for invoking the Lambda function from API Gateway |
| <a name="output_qualified_arn"></a> [qualified\_arn](#output\_qualified\_arn) | The ARN identifying your Lambda Function Version |
<!-- END_TF_DOCS -->