# 🌐 VPC Module

## Version: 0.2.0

This module provisions a Virtual Private Cloud (VPC) and related networking components in a simulated AWS environment using [LocalStack](https://localstack.cloud/) or real AWS.

---

## 📦 Features

- VPC with customizable CIDR block
- Public and private subnets (optional)
- Internet Gateway (optional)
- NAT Gateway (optional)
- Availability Zone spread
- Default security group
- Terraform-compatible outputs for chaining modules

---

## 📥 Inputs

| Name                     | Description                                           | Type            | Default              | Required |
|--------------------------|-------------------------------------------------------|------------------|----------------------|----------|
| `name`                   | Prefix used for naming all resources                 | `string`         | `"default-vpc"`      | ❌        |
| `cidr_block`             | CIDR block for the VPC                               | `string`         | `"10.0.0.0/16"`      | ❌        |
| `az_count`               | Number of Availability Zones to use                  | `number`         | `2`                  | ❌        |
| `availability_zones`     | List of AZs to use                                   | `list(string)`   | `["us-east-1a", "us-east-1b"]` | ❌        |
| `create_public_subnets`  | Whether to create public subnets                     | `bool`           | `true`               | ❌        |
| `create_private_subnets` | Whether to create private subnets                    | `bool`           | `true`               | ❌        |
| `enable_nat_gateway`     | Whether to create NAT Gateway for private subnets    | `bool`           | `false`              | ❌        |
| `tags`                   | Tags to apply to all resources                       | `map(string)`    | `{}`                 | ❌        |

---

## 📤 Outputs

| Name                 | Description                               |
|----------------------|-------------------------------------------|
| `vpc_id`             | ID of the VPC                             |
| `public_subnet_ids`  | List of public subnet IDs                 |
| `private_subnet_ids` | List of private subnet IDs                |
| `igw_id`             | Internet Gateway ID (if created)          |
| `nat_gateway_ids`    | List of NAT Gateway IDs (if created)      |
| `default_sg`         | ID of the default security group          |
| `example_output`     | Static `"ok"` used for automated testing  |

---

## 🧪 Example Usage

```hcl
module "vpc" {
  source = "../modules/vpc"

  name                   = "default-vpc"
  cidr_block             = "10.0.0.0/16"
  az_count               = 2
  availability_zones     = ["us-east-1a", "us-east-1b"]
  create_public_subnets  = true
  create_private_subnets = true
  enable_nat_gateway     = true
  tags = {
    Environment = "dev"
    Owner       = "nick"
  }

  providers = {
    aws = aws.localstack
  }
}
```

---

## 🚧 LocalStack Considerations

> ⚠️ NAT Gateway resources are **not fully supported** in LocalStack.  
Use `enable_nat_gateway = false` for best compatibility during local development.

---

## 🧪 Testing

```bash
go test -v ./modules/vpc/test/
```

---

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
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | n/a | `list(string)` | <pre>[<br/>  "us-east-1a",<br/>  "us-east-1b"<br/>]</pre> | no |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Number of Availability Zones to use | `number` | `2` | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_create_private_subnets"></a> [create\_private\_subnets](#input\_create\_private\_subnets) | Whether to create private subnets | `bool` | `true` | no |
| <a name="input_create_public_subnets"></a> [create\_public\_subnets](#input\_create\_public\_subnets) | Whether to create public subnets | `bool` | `true` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Whether to create a NAT Gateway for private subnets | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name tag for the VPC and related resources | `string` | `"default-vpc"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_sg"></a> [default\_sg](#output\_default\_sg) | ID of the default security group |
| <a name="output_example_output"></a> [example\_output](#output\_example\_output) | Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made |
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | Internet Gateway ID (if created) |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | List of NAT Gateway IDs (if created) |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the created VPC |
<!-- END_TF_DOCS -->