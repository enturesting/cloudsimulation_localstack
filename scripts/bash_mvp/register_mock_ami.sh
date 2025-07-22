#!/bin/bash

# Check if environment argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Environment must be one of: dev, develop, nonprod"
    exit 1
fi

env=$1

# Validate environment
if [[ ! "$env" =~ ^(dev|develop|nonprod)$ ]]; then
    echo "Invalid environment: $env"
    echo "Must be one of: dev, develop, nonprod"
    exit 1
fi

auto_tfvars_path="$(dirname "$0")/../environments/$env.auto.tfvars"
endpoint="http://localhost:4566"

echo "Locating known-good AMI (amazonlinux-2023) for environment: $env"

# Use AWS CLI to find the known-good image ID
if ! ami_id=$(aws ec2 describe-images \
    --endpoint-url "$endpoint" \
    --query "Images[?Name=='amazonlinux-2023'].ImageId" \
    --output text 2>/dev/null); then
    echo -e "\nError querying LocalStack for AMI."
    exit 1
fi

if [ -z "$ami_id" ]; then
    echo -e "\nFailed to locate known-good AMI: amazonlinux-2023"
    exit 1
fi

echo -e "\nFound AMI: $ami_id"

# Update ami_id in the environment's tfvars
if [ -f "$auto_tfvars_path" ]; then
    # Use sed to replace the ami_id line
    sed -i "s/ami_id\s*=\s*\".*\"/ami_id = \"$ami_id\"/" "$auto_tfvars_path"
    
    echo -e "\nUpdated $auto_tfvars_path with:"
    echo "ami_id = $ami_id"
else
    echo -e "\nFile not found: $auto_tfvars_path"
fi 