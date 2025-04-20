# 🌐 VPC Terraform Module

This module provisions a Virtual Private Cloud (VPC) and related networking components in a simulated AWS environment using [LocalStack](https://localstack.cloud/) or a real AWS account.

---

## 📦 Features

- Creates a VPC with customizable CIDR block
- Supports public and private subnets
- Configurable number of availability zones
- Internet Gateway (optional)
- Route Tables and associations
- NAT Gateway support (optional)

---

## 📁 Usage
```hcl
module "vpc" {
  source = "../modules/vpc"

  name                     = "my-vpc"
  cidr_block               = "10.0.0.0/16"
  az_count                 = 2
  create_public_subnets    = true
  create_private_subnets   = true
  enable_nat_gateway       = true
  tags = {
    Environment = var.environment
    Owner       = "terraform"
  }
}



## 🚧 Notes
NAT Gateway may not be fully supported in LocalStack.

If using with LocalStack, make sure your Terraform AWS provider is configured for path-style S3 and LocalStack endpoints.

This module is designed to be used as part of a larger modular infrastructure setup (e.g. alongside ec2, s3, iam, dynamodb modules).


## 🔧 Inputs

| Name                    | Type    | Default         | Description                                           |
|-------------------------|---------|-----------------|-------------------------------------------------------|
| `name`                  | string  | n/a (required)  | VPC name prefix                                       |
| `cidr_block`            | string  | "10.0.0.0/16"   | CIDR block for the VPC                                |
| `az_count`              | number  | 2               | Number of availability zones to use                   |
| `create_public_subnets`| bool    | true            | Whether to create public subnets                      |
| `create_private_subnets`| bool   | true            | Whether to create private subnets                     |
| `enable_nat_gateway`    | bool   | false           | Whether to create NAT Gateway for private subnet egress |
| `tags`                  | map     | `{}`            | Tags to apply to all resources                        |

---

## 📤 Outputs

| Name               | Description                              |
|--------------------|------------------------------------------|
| `vpc_id`           | ID of the created VPC                    |
| `public_subnet_ids`| List of public subnet IDs                |
| `private_subnet_ids`| List of private subnet IDs              |
| `igw_id`           | Internet Gateway ID (if created)         |
| `nat_gateway_ids`  | List of NAT Gateway IDs (if created)     |
