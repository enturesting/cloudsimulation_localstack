#!/bin/bash

root=$(pwd)
old_name="develop.tfvars"
new_name="develop.tfvars"

# Rename the tfvars file
old_path="$root/$old_name"
new_path="$root/$new_name"

if [ -f "$old_path" ]; then
    mv "$old_path" "$new_path"
    echo "Renamed '$old_name' → '$new_name'"
else
    echo "File '$old_name' not found. Skipping rename."
fi

# Update all script/code files with "develop.tfvars" reference
extensions=("*.ps1" "*.tf" "*.yml" "*.md")
for ext in "${extensions[@]}"; do
    find "$root" -type f -name "$ext" -exec sed -i 's/\bdev\.tfvars\b/develop.tfvars/g' {} +
done
echo "Updated references to '$old_name' in project files." 