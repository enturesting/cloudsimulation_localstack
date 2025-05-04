#!/bin/bash

# Get repo root
repo_root="$(dirname "$0")/.."
modules_path="$repo_root/modules"
docs_path="$repo_root/docs"

echo ""
echo "Syncing module README.md files..."

# Sync modules/*/README.md → docs/modules/*/README.md
while IFS= read -r -d '' module; do
    module_name=$(basename "$module")
    source_readme="$module/README.md"
    target_dir="$docs_path/modules/$module_name"
    target_readme="$target_dir/README.md"

    # Ensure target dir exists
    mkdir -p "$target_dir"

    # Remove any old file first to avoid caching issues
    rm -f "$target_readme"

    # Copy over the latest file
    if [ -f "$source_readme" ]; then
        cp "$source_readme" "$target_readme"
        echo "Copied module README.md: $module_name"
    else
        echo "Missing README.md in module: $module_name"
    fi
done < <(find "$modules_path" -mindepth 1 -maxdepth 1 -type d -print0)

echo ""
echo "Syncing top-level README.md files..."

# Top-level folders to process
top_level_folders=("test" "scripts" "environments")

for folder in "${top_level_folders[@]}"; do
    source_readme="$repo_root/$folder/README.md"
    target_dir="$docs_path/$folder"
    target_readme="$target_dir/README.md"

    mkdir -p "$target_dir"

    rm -f "$target_readme"

    if [ -f "$source_readme" ]; then
        cp "$source_readme" "$target_readme"
        echo "Copied top-level README.md: $folder"
    else
        echo "Missing top-level README.md: $folder"
    fi
done

echo ""
echo "All README.md files synced into docs structure." 