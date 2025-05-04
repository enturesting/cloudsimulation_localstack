#!/bin/bash

echo -e "\n==== GLOBAL TERRAFORM STATE CLEANUP ===="

# Define folders where Terraform state might live
env_paths=(
    "$(dirname "$0")/../environments"
    "$(dirname "$0")/.."
    "$(dirname "$0")/../modules"
    "$(dirname "$0")/../scripts"
    "$(dirname "$0")/../test"
)

# Files and folders to remove
tf_state_files=("terraform.tfstate" "terraform.tfstate.backup" ".terraform.lock.hcl")
tf_dirs=(".terraform" "terraform.tfstate.d")

for path in "${env_paths[@]}"; do
    if [ -d "$path" ]; then
        echo -e "\n🧹 Checking: $path"

        for file in "${tf_state_files[@]}"; do
            file_path="$path/$file"
            if [ -f "$file_path" ]; then
                if rm -f "$file_path" 2>/dev/null; then
                    echo " Removed file: $file"
                else
                    echo "⚠ Could not remove file: $file_path"
                fi
            fi
        done

        for dir in "${tf_dirs[@]}"; do
            dir_path="$path/$dir"
            if [ -d "$dir_path" ]; then
                if rm -rf "$dir_path" 2>/dev/null; then
                    echo " Removed directory: $dir"
                else
                    echo " Could not remove directory: $dir_path"
                fi
            fi
        done
    fi
done

echo -e "\n All Terraform state cleanup attempted. Locked files (if any) were skipped safely." 