# 📦 EC2 Module

## Version: 0.1.0

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
