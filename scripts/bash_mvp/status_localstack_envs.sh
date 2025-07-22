#!/bin/bash

# Define known environments and their ports
declare -A known_envs
known_envs["develop"]="4566:31566"
known_envs["nonprod"]="4567:32566"

echo -e "\nLocalStack Container Status"
echo "---------------------------"

for env in "${!known_envs[@]}"; do
    container="localstack-$env"
    status=$(docker ps -a --filter "name=$container" --format "{{.Status}}")
    
    # Split the port string into api and ui ports
    IFS=':' read -r api_port ui_port <<< "${known_envs[$env]}"
    
    if [ -n "$status" ]; then
        echo "${env}:    $container is $status"
        echo "  API Port:    http://localhost:$api_port"
        echo "  UI  Port:    http://localhost:$ui_port"
    else
        echo -e "${env}:    $container not found or not running"
    fi
    
    echo ""
done 