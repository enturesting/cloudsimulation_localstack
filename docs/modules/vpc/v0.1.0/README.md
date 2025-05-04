# 🌐 VPC Module

## Version: 0.1.0

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
