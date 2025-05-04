#!/bin/bash

echo -e "\n==== PURGING MOCK AMIs FROM LOCALSTACK ===="

# Ensure AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found in PATH."
    exit 1
fi

# Set LocalStack endpoint
endpoint="http://localhost:4566"

# Retrieve mock AMIs
if ! mock_amis=$(aws ec2 describe-images \
    --endpoint-url "$endpoint" \
    --query "Images[?starts_with(Name, 'mock-')].ImageId" \
    --output text 2>/dev/null); then
    echo "Failed to query AMIs from LocalStack."
    exit 1
fi

if [ -z "$mock_amis" ]; then
    echo "No mock AMIs found to purge."
    exit 0
fi

# Convert space-separated list to array
IFS=$'\n' read -d '' -r -a mock_amis_list <<< "$mock_amis"

for ami_id in "${mock_amis_list[@]}"; do
    echo "🧹 Deregistering AMI: $ami_id"
    aws ec2 deregister-image --image-id "$ami_id" --endpoint-url "$endpoint"
done

echo -e "\nPurge complete. Deregistered ${#mock_amis_list[@]} mock AMI(s)." 