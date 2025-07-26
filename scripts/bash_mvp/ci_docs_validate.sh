#!/bin/bash

echo "CI: Validating that each module has docs/content.md..."

# Get all module directories
modules_dir="$(dirname "$0")/../modules"
missing_docs=()

# Check each module for docs/content.md
while IFS= read -r -d '' module; do
    module_name=$(basename "$module")
    docs_path="$module/docs/content.md"
    
    if [ ! -f "$docs_path" ]; then
        missing_docs+=("$module_name")
    fi
done < <(find "$modules_dir" -mindepth 1 -maxdepth 1 -type d -print0)

if [ ${#missing_docs[@]} -eq 0 ]; then
    echo "All modules have long-form docs."
else
    echo "Missing content.md in:"
    for module in "${missing_docs[@]}"; do
        echo "$module"
    done
    exit 1
fi 