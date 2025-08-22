# LocalStack Troubleshooting Guide

This guide contains useful commands and tips for troubleshooting LocalStack issues.

## Health Checks

### Check LocalStack Health
```powershell
# PowerShell
Invoke-RestMethod -Uri http://localhost:4566/_localstack/health

# Bash
curl http://localhost:4566/_localstack/health
```

### Check Specific Environment Health
- **Develop**: http://localhost:4566/_localstack/health
- **Nonprod**: http://localhost:4567/_localstack/health
- **Staging**: http://localhost:4568/_localstack/health
- **Prod**: http://localhost:4569/_localstack/health

## AWS CLI Commands

### S3 Operations
```bash
# List S3 buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Create a bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://test-bucket

# For different environments, change the port:
aws --endpoint-url=http://localhost:4567 s3 ls  # nonprod
```

## EC2 Troubleshooting

### Check Mock AMI Registration
```powershell
# PowerShell
Invoke-RestMethod http://localhost:4566/_localstack/ami | ConvertTo-Json -Depth 5

# Bash
curl http://localhost:4566/_localstack/ami | jq
```

### View EC2 Service Logs
```powershell
# PowerShell
docker logs localstack-develop --tail=100 | Select-String "ec2"

# Bash
docker logs -f localstack-develop | grep ec2
```

### Debug EC2 Module
```powershell
# Enable debug logging
$env:TF_LOG="DEBUG"
terraform apply -target=module.ec2_instance -var-file="environments/develop.tfvars"

# Clear the log variable after
Remove-Item Env:\TF_LOG
```

## Container Management

### Stop and Remove Containers
```bash
# Stop specific environment
docker stop localstack-develop
docker rm localstack-develop

# Stop all LocalStack containers
docker stop $(docker ps -q --filter "name=localstack")
docker rm $(docker ps -aq --filter "name=localstack")
```

### Clean Terraform State
```powershell
# From environments directory
rm terraform.tfstate
rm terraform.tfstate.backup
rm -rf .terraform/
```

## Common Issues

### 1. Container Already Running
```bash
# Check running containers
docker ps --filter "name=localstack"

# Force remove if needed
docker rm -f localstack-develop
```

### 2. Port Already in Use
```bash
# Check what's using the port (Linux/Mac)
lsof -i :4566

# Windows PowerShell
netstat -ano | findstr :4566
```

### 3. LocalStack Not Starting
1. Check Docker is running
2. Verify ports are available
3. Check LocalStack logs: `docker logs localstack-develop`
4. Ensure API key is set (for Pro features)

### 4. Terraform State Issues
```bash
# Reset workspace
terraform workspace select default
terraform workspace delete develop

# Recreate workspace
terraform workspace new develop
```

## Useful Environment Variables

```powershell
# Enable debug mode
$env:DEBUG=1

# Set specific log level
$env:TF_LOG="DEBUG"  # or TRACE, INFO, WARN, ERROR

# LocalStack configuration
$env:LOCALSTACK_HOST="localhost"
$env:AWS_DEFAULT_REGION="us-east-1"
```

## Tips

1. **Always specify the endpoint URL** when using AWS CLI with LocalStack
2. **Use workspace isolation** to keep environments separate
3. **Monitor container logs** for real-time debugging
4. **Clean state regularly** when switching between environments
5. **Use the Web UI** (Pro only) for visual debugging: http://localhost:31566

## Getting Help

1. Check container logs first: `docker logs localstack-develop`
2. Verify your `.auto.tfvars` files have correct settings
3. Test basic connectivity: `curl http://localhost:4566/_localstack/health`
4. Review the main README.md for setup instructions
5. Use `terraform plan` before `apply` to catch issues early