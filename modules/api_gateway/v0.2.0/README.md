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
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_method.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_resource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the environment | `string` | n/a | yes |
| <a name="input_lambda_invoke_arn"></a> [lambda\_invoke\_arn](#input\_lambda\_invoke\_arn) | ARN of the Lambda function to invoke | `string` | n/a | yes |
| <a name="input_methods"></a> [methods](#input\_methods) | List of HTTP methods to enable | `list(string)` | <pre>[<br/>  "GET",<br/>  "POST"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the API Gateway | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Base path for the API Gateway | `string` | `"api"` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name of the API Gateway stage | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the API Gateway | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_execution_arn"></a> [execution\_arn](#output\_execution\_arn) | The execution ARN part to be used in lambda\_permission's source\_arn |
| <a name="output_invoke_url"></a> [invoke\_url](#output\_invoke\_url) | The URL to invoke the API Gateway |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The resource ID of the API Gateway resource |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | The ID of the REST API |
| <a name="output_root_resource_id"></a> [root\_resource\_id](#output\_root\_resource\_id) | The resource ID of the REST API's root |
| <a name="output_stage_arn"></a> [stage\_arn](#output\_stage\_arn) | The ARN of the stage |
<!-- END_TF_DOCS -->