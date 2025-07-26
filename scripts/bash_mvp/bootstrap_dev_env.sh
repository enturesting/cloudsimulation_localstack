#!/bin/bash

echo -e "\n🧪 Bootstrapping Terraform Local Dev Environment..."

# Run the scripts in sequence
"$(dirname "$0")/reset_localstack.sh" develop
"$(dirname "$0")/apply_env.sh" develop
"$(dirname "$0")/launch_localstack_docs.sh" 