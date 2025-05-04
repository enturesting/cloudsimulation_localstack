output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  value       = [for subnet in aws_subnet.public : subnet.id]
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "IDs of the private subnets"
}

output "igw_id" {
  description = "Internet Gateway ID (if created)"
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs (if created)"
  value       = aws_nat_gateway.this[*].id
}

# Being put here to help MVP the automated Go testing per module. Will remove later when later version of go tests is made
output "example_output" {
  value = "ok"
}

output "default_sg" {
  description = "ID of the default security group"
  value       = aws_security_group.default.id
}