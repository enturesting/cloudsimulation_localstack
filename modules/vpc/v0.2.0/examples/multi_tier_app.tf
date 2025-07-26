# Example: Multi-tier Application VPC
# This example shows how to create a VPC for a multi-tier web application

module "app_vpc" {
  source = "../"
  
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  environment_name     = "prod"
  
  # Public subnets for load balancers
  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
  
  # Private subnets for application servers
  private_subnets = [
    "10.0.10.0/24",
    "10.0.20.0/24",
    "10.0.30.0/24"
  ]
  
  # Database subnets for RDS
  database_subnets = [
    "10.0.100.0/24",
    "10.0.200.0/24",
    "10.0.300.0/24"
  ]
  
  # Enable NAT gateways for private subnet internet access
  enable_nat_gateway     = true
  single_nat_gateway     = false  # Multi-AZ NAT for high availability
  
  # Enable VPC endpoints for AWS services
  enable_s3_endpoint     = true
  enable_dynamodb_endpoint = true
  
  # DNS settings
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Environment = "production"
    Project     = "web-app"
    Team        = "infrastructure"
    CostCenter  = "engineering"
  }
}

# Security Groups for different tiers

# Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for Application Load Balancer"
  vpc_id      = module.app_vpc.vpc_id
  
  # Allow HTTP and HTTPS from internet
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "alb-security-group"
    Environment = "production"
    Tier        = "public"
  }
}

# Web Tier Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-tier-security-group"
  description = "Security group for web tier instances"
  vpc_id      = module.app_vpc.vpc_id
  
  # Allow HTTP from ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  
  # Allow SSH from bastion
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "web-tier-security-group"
    Environment = "production"
    Tier        = "private"
  }
}

# Application Tier Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-tier-security-group"
  description = "Security group for application tier instances"
  vpc_id      = module.app_vpc.vpc_id
  
  # Allow application port from web tier
  ingress {
    description     = "App port from web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  
  # Allow SSH from bastion
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "app-tier-security-group"
    Environment = "production"
    Tier        = "private"
  }
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  name        = "database-security-group"
  description = "Security group for database instances"
  vpc_id      = module.app_vpc.vpc_id
  
  # Allow MySQL/PostgreSQL from app tier
  ingress {
    description     = "Database from app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  
  # PostgreSQL alternative
  ingress {
    description     = "PostgreSQL from app tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
  
  tags = {
    Name        = "database-security-group"
    Environment = "production"
    Tier        = "database"
  }
}

# Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-security-group"
  description = "Security group for bastion host"
  vpc_id      = module.app_vpc.vpc_id
  
  # Allow SSH from specific IP ranges (company IPs)
  ingress {
    description = "SSH from company network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "bastion-security-group"
    Environment = "production"
    Tier        = "public"
  }
}

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.app_vpc.public_subnet_ids
  
  enable_deletion_protection = true
  
  tags = {
    Name        = "app-load-balancer"
    Environment = "production"
    Tier        = "public"
  }
}

# Database Subnet Group
resource "aws_db_subnet_group" "app_db_subnet_group" {
  name       = "app-database-subnet-group"
  subnet_ids = module.app_vpc.database_subnet_ids
  
  tags = {
    Name        = "app-database-subnet-group"
    Environment = "production"
    Tier        = "database"
  }
}

# Variables
variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH to bastion host"
  type        = list(string)
  default     = ["10.0.0.0/8"]  # Private networks only by default
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.app_vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.app_vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.app_vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.app_vpc.database_subnet_ids
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "web_security_group_id" {
  description = "ID of the web tier security group"
  value       = aws_security_group.web_sg.id
}

output "app_security_group_id" {
  description = "ID of the app tier security group"
  value       = aws_security_group.app_sg.id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db_sg.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion_sg.id
}

output "load_balancer_arn" {
  description = "ARN of the application load balancer"
  value       = aws_lb.app_alb.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.app_alb.dns_name
}