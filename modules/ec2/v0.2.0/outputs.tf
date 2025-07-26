output "instance_id" {
  value       = aws_instance.this.id
  description = "EC2 instance ID"
}

output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "EC2 public IP"
}

output "private_ip" {
  value       = aws_instance.this.private_ip
  description = "EC2 private IP"
}

# Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made
output "example_output" {
  value = "ok"
}
