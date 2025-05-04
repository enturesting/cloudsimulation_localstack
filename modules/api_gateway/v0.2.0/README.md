# API Gateway Module

## Version: 0.2.0

This module creates an AWS API Gateway REST API with Lambda integration, configurable methods, and deployment stages.

## Usage

```hcl
module "api_gateway" {
  source = "./modules/api_gw"

  api_name        = "my-api"
  api_description = "My API Gateway"
  resource_path   = "{proxy+}"
  http_method     = "ANY"
  authorization   = "NONE"
  lambda_invoke_arn = module.lambda.invoke_arn
  stage_name      = "dev"

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| api_name | The name of the REST API | string | n/a | yes |
| api_description | The description of the REST API | string | "Managed by Terraform" | no |
| resource_path | The last path segment of this API resource | string | "{proxy+}" | no |
| http_method | The HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY) | string | "ANY" | no |
| authorization | The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS) | string | "NONE" | no |
| authorizer_id | The authorizer id to be used when the authorization is CUSTOM or COGNITO_USER_POOLS | string | null | no |
| lambda_invoke_arn | The ARN to be used for invoking a Lambda function from API Gateway | string | n/a | yes |
| stage_name | The name of the stage | string | "dev" | no |
| tags | A mapping of tags to assign to the API Gateway | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| api_id | The ID of the REST API |
| root_resource_id | The resource ID of the REST API's root |
| execution_arn | The execution ARN part to be used in lambda_permission's source_arn |
| invoke_url | The URL to invoke the API pointing to the stage |
| stage_arn | The ARN of the stage | 
