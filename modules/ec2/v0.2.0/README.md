# 📦 EC2 Module

## Version: 0.2.0

Provisions a single EC2 instance for use with LocalStack or AWS-like simulated environments. Supports optional `user_data`, tagging, key pair injection, and VPC configuration via subnet and security groups.

---

## 📥 Inputs

| Name              | Description                                     | Type             | Default      |
|-------------------|-------------------------------------------------|------------------|--------------|
| `ami_id`          | AMI ID to use for the instance                  | `string`         | n/a          |
| `instance_type`   | EC2 instance type                               | `string`         | `"t2.micro"` |
| `user_data`       | Optional shell script to bootstrap the instance | `string`         | `""`         |
| `subnet_id`       | Subnet ID for the instance                      | `string`         | `null`       |
| `security_groups` | List of security group IDs                      | `list(string)`   | `[]`         |
| `key_name`        | Name of the SSH key pair                        | `string`         | `null`       |
| `tags`            | Additional tags to apply                        | `map(string)`    | `{}`         |

---

## 📤 Outputs

| Name         | Description                 |
|--------------|-----------------------------|
| `instance_id`| EC2 instance ID             |
| `public_ip`  | EC2 public IP address       |
| `private_ip` | EC2 private IP address      |
| `example_output` | Static "ok" output (for Terratest MVP) |

---

## 🧪 Example Usage

```hcl
module "ec2_instance" {
  source        = "../modules/ec2"
  ami_id        = "ami-024f768332f0"
  instance_type = "t3.micro"
  subnet_id     = "subnet-abc123"
  security_groups = ["sg-xyz789"]
  user_data     = file("scripts/init.sh")
  key_name      = "my-keypair"

  tags = {
    Environment = "develop"
    Owner       = "nick"
  }

  providers = {
    aws = aws.localstack
  }
}
```

---

## 💡 Notes

- `tags` will be merged with a default `Name=localstack-ec2` and `Environment=local`.
- Works seamlessly in LocalStack using a mock AMI registered via `register_mock_ami.ps1`.
- The `example_output` is a placeholder for test tooling scaffolding and may be removed later.

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
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID for EC2 instance | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key pair name for SSH access | `string` | `null` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security group IDs | `list(string)` | `[]` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID to launch the instance in | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to the instance | `map(string)` | `{}` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data script for EC2 instance | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example_output"></a> [example\_output](#output\_example\_output) | Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 instance ID |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | EC2 private IP |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | EC2 public IP |
<!-- END_TF_DOCS -->