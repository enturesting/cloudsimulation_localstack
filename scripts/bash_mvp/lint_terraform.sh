#!/bin/bash
set -e

# Terraform hygiene and linting script
# Runs terraform fmt and validate across all modules and environments

echo "🧹 Running Terraform hygiene checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOTAL_DIRS=0
FAILED_DIRS=0

# Function to check terraform in a directory
check_terraform_dir() {
    local dir="$1"
    local name="$2"
    
    echo -e "${CYAN}📁 Checking: $name${NC}"
    
    if ! terraform -chdir="$dir" fmt -check=true -diff=true; then
        echo -e "${YELLOW}⚠️  Formatting issues found in $name${NC}"
        echo -e "${YELLOW}   Running terraform fmt...${NC}"
        terraform -chdir="$dir" fmt
        echo -e "${GREEN}✅ Fixed formatting in $name${NC}"
    else
        echo -e "${GREEN}✅ Formatting OK: $name${NC}"
    fi
    
    if ! terraform -chdir="$dir" validate; then
        echo -e "${RED}❌ Validation failed: $name${NC}"
        return 1
    else
        echo -e "${GREEN}✅ Validation OK: $name${NC}"
    fi
    
    return 0
}

# Check environments
echo -e "${CYAN}🏗️  Checking environments...${NC}"
ENVIRONMENTS_DIR="../environments"
if [ -d "$ENVIRONMENTS_DIR" ]; then
    ((TOTAL_DIRS++))
    if check_terraform_dir "$ENVIRONMENTS_DIR" "environments"; then
        echo -e "${GREEN}✅ Environments check passed${NC}"
    else
        echo -e "${RED}❌ Environments check failed${NC}"
        ((FAILED_DIRS++))
    fi
else
    echo -e "${YELLOW}⚠️  Environments directory not found${NC}"
fi

# Check backend
echo -e "${CYAN}🔧 Checking backend...${NC}"
BACKEND_DIR="../backend"
if [ -d "$BACKEND_DIR" ]; then
    ((TOTAL_DIRS++))
    if check_terraform_dir "$BACKEND_DIR" "backend"; then
        echo -e "${GREEN}✅ Backend check passed${NC}"
    else
        echo -e "${RED}❌ Backend check failed${NC}"
        ((FAILED_DIRS++))
    fi
else
    echo -e "${YELLOW}⚠️  Backend directory not found${NC}"
fi

# Check all modules
echo -e "${CYAN}📦 Checking modules...${NC}"
MODULES_DIR="../modules"
if [ -d "$MODULES_DIR" ]; then
    for module_type in "$MODULES_DIR"/*; do
        if [ -d "$module_type" ]; then
            module_name=$(basename "$module_type")
            echo -e "${CYAN}📦 Processing module: $module_name${NC}"
            
            # Check each version
            for version_dir in "$module_type"/v*.*.*; do
                if [ -d "$version_dir" ]; then
                    version_name=$(basename "$version_dir")
                    ((TOTAL_DIRS++))
                    
                    # Check if directory has terraform files
                    if ! find "$version_dir" -name "*.tf" -type f | grep -q .; then
                        echo -e "${YELLOW}⚠️  No .tf files found in $module_name/$version_name, skipping${NC}"
                        ((TOTAL_DIRS--))
                        continue
                    fi
                    
                    if check_terraform_dir "$version_dir" "$module_name/$version_name"; then
                        echo -e "${GREEN}✅ Module $module_name/$version_name check passed${NC}"
                    else
                        echo -e "${RED}❌ Module $module_name/$version_name check failed${NC}"
                        ((FAILED_DIRS++))
                    fi
                fi
            done
        fi
    done
else
    echo -e "${YELLOW}⚠️  Modules directory not found${NC}"
fi

# Summary
echo ""
echo -e "${CYAN}📊 Summary:${NC}"
echo -e "   Total directories checked: $TOTAL_DIRS"
echo -e "   Failed directories: $FAILED_DIRS"
echo -e "   Success rate: $(( (TOTAL_DIRS - FAILED_DIRS) * 100 / TOTAL_DIRS ))%"

if [ $FAILED_DIRS -eq 0 ]; then
    echo -e "${GREEN}🎉 All Terraform hygiene checks passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED_DIRS directories failed hygiene checks${NC}"
    exit 1
fi