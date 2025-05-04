#!/bin/bash

modules_path="$(dirname "$0")/../modules"

echo "🔍 Validating metadata.json for all modules..."

errors=()

# Find all metadata.json files and validate them
while IFS= read -r -d '' file; do
    if ! jq -e '.name and .description and .terraform_version' "$file" > /dev/null 2>&1; then
        errors+=("❌ Missing required field in: $file")
    fi
done < <(find "$modules_path" -name "metadata.json" -print0)

if [ ${#errors[@]} -eq 0 ]; then
    echo -e "\n✅ All metadata.json files are valid."
else
    echo -e "\nErrors found:"
    for error in "${errors[@]}"; do
        echo "$error"
    done
    exit 1
fi 