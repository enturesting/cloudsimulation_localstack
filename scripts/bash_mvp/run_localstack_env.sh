#!/bin/bash

# Default environment
env=${1:-"develop"}

# Port mapping per environment
declare -A ports
ports["develop"]="4566:31566"
ports["nonprod"]="4567:32566"

if [ -z "${ports[$env]}" ]; then
    echo "Unknown environment: $env. Allowed: develop, nonprod"
    exit 1
fi

# Split the port string into api and ui ports
IFS=':' read -r api_port ui_port <<< "${ports[$env]}"
container_name="localstack-$env"
volume_name="localstack-vol-$env"

# Load LOCALSTACK_AUTH_TOKEN
env_file="environments/$env.auto.tfvars"
if [ -f "$env_file" ]; then
    localstack_api_key=$(grep -oP 'localstack_api_key\s*=\s*"\K[^"]+' "$env_file")
    if [ -n "$localstack_api_key" ]; then
        export LOCALSTACK_AUTH_TOKEN="$localstack_api_key"
        echo "Loaded LOCALSTACK_AUTH_TOKEN from $env_file"
    else
        echo "'localstack_api_key' not found in $env_file"
        exit 1
    fi
else
    echo "$env_file not found."
    exit 1
fi

# Start container
docker run -d --name "$container_name" \
    -p "${api_port}:4566" \
    -p "${ui_port}:31566" \
    -e LOCALSTACK_AUTH_TOKEN="$LOCALSTACK_AUTH_TOKEN" \
    -e LOCALSTACK_HOST=localhost \
    -e LS_PLATFORM_MULTI_ACCOUNT=true \
    -v "${volume_name}:/var/lib/localstack" \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    localstack/localstack-pro

sleep 10
echo -e "\nLocalStack ($env) started at:"
echo "  API: http://localhost:$api_port"
echo "  UI : http://localhost:$ui_port" 