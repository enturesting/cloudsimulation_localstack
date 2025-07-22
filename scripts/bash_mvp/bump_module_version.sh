#!/bin/bash
set -e

# Bump module version using semantic versioning
# Creates new version directories and updates module version constraints

MODULE_NAME=""
VERSION_TYPE=""
NEW_VERSION=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--module)
            MODULE_NAME="$2"
            shift 2
            ;;
        -t|--type)
            VERSION_TYPE="$2"
            shift 2
            ;;
        -v|--version)
            NEW_VERSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 -m|--module MODULE_NAME -t|--type VERSION_TYPE [-v|--version NEW_VERSION]"
            echo "Version types: major, minor, patch"
            echo "Example: $0 -m s3 -t minor"
            echo "Example: $0 -m s3 -v 0.2.0"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [ -z "$MODULE_NAME" ]; then
    echo "❌ Module name is required"
    echo "Usage: $0 -m|--module MODULE_NAME -t|--type VERSION_TYPE"
    exit 1
fi

# Set script directory and module path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$SCRIPT_DIR/../../modules/$MODULE_NAME"

if [ ! -d "$MODULE_DIR" ]; then
    echo "❌ Module directory not found: $MODULE_DIR"
    exit 1
fi

echo "🔍 Processing module: $MODULE_NAME"

# Get current latest version
CURRENT_VERSION=""
for version_dir in "$MODULE_DIR"/v*.*.*; do
    if [ -d "$version_dir" ]; then
        version=$(basename "$version_dir" | sed 's/^v//')
        if [ -z "$CURRENT_VERSION" ] || [ "$(printf '%s\n' "$version" "$CURRENT_VERSION" | sort -V | tail -n1)" = "$version" ]; then
            CURRENT_VERSION="$version"
        fi
    fi
done

if [ -z "$CURRENT_VERSION" ]; then
    echo "❌ No existing versions found in $MODULE_DIR"
    exit 1
fi

echo "📋 Current version: v$CURRENT_VERSION"

# Calculate new version if not provided
if [ -z "$NEW_VERSION" ]; then
    if [ -z "$VERSION_TYPE" ]; then
        echo "❌ Either version type or explicit version is required"
        exit 1
    fi
    
    IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
    MAJOR="${VERSION_PARTS[0]}"
    MINOR="${VERSION_PARTS[1]}"
    PATCH="${VERSION_PARTS[2]}"
    
    case $VERSION_TYPE in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        patch)
            PATCH=$((PATCH + 1))
            ;;
        *)
            echo "❌ Invalid version type. Use: major, minor, or patch"
            exit 1
            ;;
    esac
    
    NEW_VERSION="$MAJOR.$MINOR.$PATCH"
fi

echo "🚀 New version: v$NEW_VERSION"

# Validate version format
if ! echo "$NEW_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "❌ Invalid version format. Use semantic versioning (e.g., 1.0.0)"
    exit 1
fi

NEW_VERSION_DIR="$MODULE_DIR/v$NEW_VERSION"

if [ -d "$NEW_VERSION_DIR" ]; then
    echo "❌ Version v$NEW_VERSION already exists"
    exit 1
fi

# Copy current version to new version
CURRENT_VERSION_DIR="$MODULE_DIR/v$CURRENT_VERSION"
echo "📁 Copying $CURRENT_VERSION_DIR to $NEW_VERSION_DIR"
cp -r "$CURRENT_VERSION_DIR" "$NEW_VERSION_DIR"

# Update version.tf if it exists
VERSION_TF="$NEW_VERSION_DIR/version.tf"
if [ -f "$VERSION_TF" ]; then
    echo "📝 Updating version.tf"
    
    # Create updated version.tf content
    cat > "$VERSION_TF" << EOF
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Module version: v$NEW_VERSION
EOF
fi

# Update README if it exists
README_FILE="$NEW_VERSION_DIR/README.md"
if [ -f "$README_FILE" ]; then
    echo "📝 Updating README.md"
    sed -i "s/Version: v$CURRENT_VERSION/Version: v$NEW_VERSION/g" "$README_FILE"
fi

# Update any examples
EXAMPLES_DIR="$NEW_VERSION_DIR/examples"
if [ -d "$EXAMPLES_DIR" ]; then
    echo "📝 Updating examples"
    find "$EXAMPLES_DIR" -name "*.tf" -exec sed -i "s|modules/$MODULE_NAME/v$CURRENT_VERSION|modules/$MODULE_NAME/v$NEW_VERSION|g" {} \;
fi

echo ""
echo "🎉 Version bump complete!"
echo "📁 New version created: $NEW_VERSION_DIR"
echo "📝 Don't forget to:"
echo "   1. Update the module code if needed"
echo "   2. Run tests: pytest test/python/${MODULE_NAME}_test.py"
echo "   3. Generate docs: ./scripts/generate_docs.sh"
echo "   4. Update your terraform configurations to use the new version"