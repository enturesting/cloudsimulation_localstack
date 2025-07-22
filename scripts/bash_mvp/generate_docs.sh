#!/bin/bash
set -e

# Generate terraform-docs for all modules
# This script uses terraform-docs to generate consistent documentation for all modules

MODULE_DIR="${1:-../modules}"

# Check if terraform-docs is installed
if ! command -v terraform-docs &> /dev/null; then
    echo "❌ terraform-docs not found. Please install it first:"
    echo "  Linux/macOS: brew install terraform-docs"
    echo "  Or download from: https://github.com/terraform-docs/terraform-docs/releases"
    exit 1
fi

echo "🔍 Discovering module directories..."

TOTAL_MODULES=0

# Get all module directories with versions
for module_type in "$MODULE_DIR"/*; do
    if [ -d "$module_type" ]; then
        module_name=$(basename "$module_type")
        echo "📦 Processing module type: $module_name"
        
        # Get version directories
        for version_dir in "$module_type"/v*.*.*; do
            if [ -d "$version_dir" ]; then
                version_name=$(basename "$version_dir")
                echo "  📝 Generating docs for: $module_name/$version_name"
                
                # Check if module has terraform files
                if ! find "$version_dir" -name "*.tf" -type f | grep -q .; then
                    echo "  ⚠️ No .tf files found in $version_dir, skipping"
                    continue
                fi
                
                # Create header file if it doesn't exist
                header_path="$version_dir/header.md"
                if [ ! -f "$header_path" ]; then
                    cat > "$header_path" << EOF
# ${module_name^^} Module

Version: $version_name

This module provisions $module_name resources on AWS using LocalStack for local development.
EOF
                fi
                
                # Create footer file if it doesn't exist
                footer_path="$version_dir/footer.md"
                if [ ! -f "$footer_path" ]; then
                    cat > "$footer_path" << EOF

## Contributing

1. Update the module code
2. Run tests: \`pytest test/python/${module_name}_test.py\`
3. Generate docs: \`./scripts/generate_docs.sh\`
4. Create a new version if needed: \`./scripts/bump_module_version.sh\`

## License

This module is part of the cloudsimulation_localstack project.
EOF
                fi
                
                # Generate documentation
                config_path="$(dirname "$0")/../.terraform-docs.yml"
                if (cd "$version_dir" && terraform-docs -c "$config_path" .); then
                    echo "  ✅ Documentation generated successfully"
                    ((TOTAL_MODULES++))
                else
                    echo "  ❌ Failed to generate docs"
                fi
            fi
        done
    fi
done

echo ""
echo "🎉 Documentation generation complete! Updated $TOTAL_MODULES modules."
echo "📚 Don't forget to run sync_all_docsify_readmes.sh to update the docs site."