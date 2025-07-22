#!/bin/bash

# Check if environment argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Environment must be one of: develop, nonprod, feature"
    exit 1
fi

env=$1

# Validate environment
if [[ ! "$env" =~ ^(develop|nonprod|feature)$ ]]; then
    echo "Invalid environment: $env"
    echo "Must be one of: develop, nonprod, feature"
    exit 1
fi

original_location=$(pwd)

# Define paths
env_dir="environments"
tfvars_file="$env_dir/$env.tfvars"
secrets_file="$env_dir/$env.auto.tfvars"
plan_file=".tfplan"

# Check for required files
if [ ! -f "$env_dir/main.tf" ]; then
    echo "Terraform files not found in: $env_dir"
    exit 1
fi

if [ ! -f "$tfvars_file" ]; then
    echo "tfvars file not found: $tfvars_file"
    exit 1
fi

if [ ! -f "$secrets_file" ]; then
    echo "Required secrets file not found: $secrets_file"
    echo "You can create it from the example:"
    echo "   cp example.auto.tfvars.template $env.auto.tfvars"
    exit 1
fi

# Load account_id and credentials from the secrets file
account_id=$(grep -oP 'account_id\s*=\s*"\K[^"]+' "$secrets_file")
access_key=$(grep -oP 'access_key\s*=\s*"\K[^"]+' "$secrets_file")
secret_key=$(grep -oP 'secret_key\s*=\s*"\K[^"]+' "$secrets_file")

if [ -z "$account_id" ] || [ -z "$access_key" ] || [ -z "$secret_key" ]; then
    echo -e "\nMissing required keys in $secrets_file:\n\nExpected keys:"
    echo "  - account_id"
    echo "  - access_key"
    echo "  - secret_key"
    echo -e "\nPlease check your secrets file or regenerate from the example."
    exit 1
fi

export AWS_ACCOUNT_ID="$account_id"
export AWS_ACCESS_KEY_ID="$access_key"
export AWS_SECRET_ACCESS_KEY="$secret_key"

# Navigate to environment directory
cd "$env_dir" || exit 1

# Terraform init
echo -e "\nInitializing Terraform for '$env'..."
terraform init

# Switch to workspace if needed
current=$(terraform workspace show)
if [ "$current" != "$env" ]; then
    echo -e "\nSwitching to workspace '$env'"
    if terraform workspace list | grep -q "\b$env\b"; then
        terraform workspace select "$env"
    else
        terraform workspace new "$env"
    fi
fi

# Terraform plan
echo -e "\nGenerating plan for '$env'..."
terraform plan -var-file="$env.tfvars" -out="$plan_file"

# Prompt for apply
echo -e "\nReview the plan above. Do you want to proceed with applying changes? (y/n): "
read -r response
if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
    echo -e "\nAborting apply operation."
    rm -f "$plan_file"
    cd "$original_location" || exit 1
    exit 0
fi

# Terraform apply
echo -e "\nApplying changes for '$env'..."
terraform apply "$plan_file"

# Cleanup
rm -f "$plan_file"
echo -e "\nDone!"

# Return to original directory
cd "$original_location" || exit 1
echo -e "\nDone! Returned to root: $original_location" 