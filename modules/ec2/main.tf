terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.28.0"
    }
  }
}



resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_groups
  key_name               = var.key_name
  user_data              = var.user_data

  tags = merge({
    Name        = "localstack-ec2"
    Environment = "local"
  }, var.tags)
}
