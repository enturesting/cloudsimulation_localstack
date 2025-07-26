#!/bin/bash

# Check if module path is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <module-path>"
    echo "Example: $0 modules/s3"
    echo ""
    echo "Description:"
    echo "  - If README.md already exists in the module folder, terraform-docs output is displayed to the terminal."
    echo "  - If README.md does not exist, a new README.md is created with a title heading and terraform-docs documentation appended."
    echo ""
    echo "Requires terraform-docs to be installed and available in PATH."
    exit 1
fi

module_path="$1"

# Show help if requested
if [ "$module_path" = "-help" ] || [ "$module_path" = "--help" ]; then
    echo "Usage: $0 <module-path>"
    echo "Example: $0 modules/s3"
    echo ""
    echo "Description:"
    echo "  - If README.md already exists in the module folder, terraform-docs output is displayed to the terminal."
    echo "  - If README.md does not exist, a new README.md is created with a title heading and terraform-docs documentation appended."
    echo ""
    echo "Requires terraform-docs to be installed and available in PATH."
    exit 0
fi

if [ ! -d "$module_path" ]; then
    echo "Error: Module path '$module_path' does not exist."
    exit 1
fi

readme_path="$module_path/README.md"

# Try running terraform-docs first to verify it's working
if ! terraform_docs_output=$(terraform-docs markdown table "$module_path" 2>&1); then
    echo "terraform-docs failed. Output:"
    echo "$terraform_docs_output"
    exit 1
fi

# Now check if README exists
if [ -f "$readme_path" ]; then
    echo "ℹREADME.md already exists in $module_path. Showing terraform-docs output below:"
    echo -e "\n================== terraform-docs Output ==================\n"
    echo "$terraform_docs_output"
else
    echo "README.md does not exist. Creating a new one with heading and terraform-docs output..."

    # Generate title from folder name
    module_name=$(basename "$module_path")
    title="# $module_name Module\n"

    # Write title + terraform-docs output
    echo -e "$title" > "$readme_path"
    echo "$terraform_docs_output" >> "$readme_path"

    echo "README.md created at $readme_path"
fi 