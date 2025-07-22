#!/bin/bash

# Default environment
env=${1:-"develop"}

container_name="localstack-$env"
volume_name="localstack-vol-$env"

# Set ports based on environment
case $env in
    "develop")
        ui_port=31566
        api_port=4566
        service_port_range="4510-4559"
        https_port=8443
        ;;
    "nonprod")
        ui_port=31567
        api_port=4567
        service_port_range="4610-4659"
        https_port=8444
        ;;
    *)
        ui_port=31568
        api_port=4568
        service_port_range="4710-4759"
        https_port=8445
        ;;
esac

echo "Resetting LocalStack for environment: $env"
echo "Container: $container_name"
echo "Volume: $volume_name"
echo "UI Port: $ui_port"

# Stop and remove container
echo "Stopping and removing container..."
docker stop "$container_name" > /dev/null 2>&1
docker rm "$container_name" > /dev/null 2>&1

# Remove volume
echo "Removing volume (if it exists)..."
docker volume rm "$volume_name" -f > /dev/null 2>&1

# Check for port conflict
port_check=$(docker ps --filter "publish=$ui_port" --format "{{.Names}}")
if [ -n "$port_check" ]; then
    echo -e "\n Port $ui_port is already in use by container: $port_check"
    echo "Please stop or remove that container manually before resetting this environment."
    echo "Example: docker stop $port_check; docker rm $port_check"
    exit 1
fi

# Load LOCALSTACK_AUTH_TOKEN
env_file="environments/$env.auto.tfvars"
if [ ! -f "$env_file" ]; then
    echo -e "\n $env_file not found."
    echo "You must provide a valid .auto.tfvars file with localstack_api_key for this environment."
    exit 1
fi

localstack_api_key=$(grep -oP 'localstack_api_key\s*=\s*"\K[^"]+' "$env_file")
if [ -z "$localstack_api_key" ]; then
    echo -e "\n Missing 'localstack_api_key' in $env_file."
    exit 1
fi

export LOCALSTACK_AUTH_TOKEN="$localstack_api_key"
echo "Loaded LOCALSTACK_AUTH_TOKEN from $env_file"

# Run LocalStack container
docker run -d --name "$container_name" \
  -p "${api_port}:4566" \
  -p "${service_port_range}:${service_port_range}" \
  -p "${ui_port}:8080" \
  -p "${https_port}:443" \
  -e LOCALSTACK_AUTH_TOKEN="$LOCALSTACK_AUTH_TOKEN" \
  -e LOCALSTACK_HOST=localhost \
  -e LS_PLATFORM_MULTI_ACCOUNT=true \
  -v "/var/run/docker.sock:/var/run/docker.sock" \
  -v "${volume_name}:/var/lib/localstack" \
  localstack/localstack-pro

sleep 10
echo -e "\n LocalStack ($env) has been reset and restarted."
echo "UI available at: http://localhost:$ui_port"

# Optional health check
if command -v curl >/dev/null 2>&1; then
    if curl -s http://localhost:4566/_localstack/health > /dev/null; then
        echo -e "\nLocalStack Health Status:"
        curl -s http://localhost:4566/_localstack/health | jq .
    else
        echo -e "\n Health check failed. LocalStack may not be fully ready yet."
    fi
else
    echo -e "\n curl not available. Skipping health check."
fi 