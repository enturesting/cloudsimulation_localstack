#!/bin/bash
set -e

# Clean reset script - destroys all Terraform resources and LocalStack state
# WARNING: This will destroy all infrastructure and reset LocalStack

ENVIRONMENT=""
FORCE=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 -e|--environment ENVIRONMENT [-f|--force]"
            echo "Example: $0 -e develop"
            echo "Example: $0 -e develop --force"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [ -z "$ENVIRONMENT" ]; then
    echo "❌ Environment is required"
    echo "Usage: $0 -e|--environment ENVIRONMENT"
    exit 1
fi

echo "🧹 Clean reset for environment: $ENVIRONMENT"
echo "⚠️  WARNING: This will destroy all infrastructure and reset LocalStack"

if [ "$FORCE" != true ]; then
    echo -n "Are you sure you want to continue? (y/N): "
    read -r confirmation
    if [[ ! "$confirmation" =~ ^[Yy]$ ]]; then
        echo "❌ Operation cancelled"
        exit 0
    fi
fi

# Create log file
LOG_DIR="$SCRIPT_DIR/../../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/clean_reset_$(date +%Y-%m-%d_%H-%M-%S).log"

echo "📋 Logging to: $LOG_FILE"

{
    echo "=== Clean Reset Started: $(date) ==="
    echo "Environment: $ENVIRONMENT"
    echo ""
    
    # Step 1: Destroy Terraform resources in environments
    ENVIRONMENTS_DIR="$SCRIPT_DIR/../../environments"
    if [ -d "$ENVIRONMENTS_DIR" ]; then
        echo "🔥 Step 1: Destroying Terraform resources in environments..."
        cd "$ENVIRONMENTS_DIR"
        
        # Check if terraform is initialized
        if [ -d ".terraform" ]; then
            echo "Destroying infrastructure..."
            if terraform destroy -var-file="${ENVIRONMENT}.tfvars" -var-file="${ENVIRONMENT}.auto.tfvars" -auto-approve; then
                echo "✅ Infrastructure destroyed successfully"
            else
                echo "⚠️  Infrastructure destroy had issues (this is normal if resources were already gone)"
            fi
        else
            echo "⚠️  Terraform not initialized in environments, skipping"
        fi
    else
        echo "⚠️  Environments directory not found, skipping"
    fi
    
    # Step 2: Destroy backend infrastructure
    BACKEND_DIR="$SCRIPT_DIR/../../backend"
    if [ -d "$BACKEND_DIR" ]; then
        echo "🔥 Step 2: Destroying backend infrastructure..."
        cd "$BACKEND_DIR"
        
        if [ -d ".terraform" ] && [ -f "backend.${ENVIRONMENT}.auto.tfvars" ]; then
            echo "Destroying backend..."
            if terraform destroy -var-file="backend.${ENVIRONMENT}.auto.tfvars" -auto-approve; then
                echo "✅ Backend destroyed successfully"
            else
                echo "⚠️  Backend destroy had issues (this is normal if resources were already gone)"
            fi
        else
            echo "⚠️  Backend not initialized or tfvars not found, skipping"
        fi
    else
        echo "⚠️  Backend directory not found, skipping"
    fi
    
    # Step 3: Clean up Terraform state files
    echo "🧹 Step 3: Cleaning up Terraform state files..."
    
    # Clean environments
    cd "$ENVIRONMENTS_DIR" 2>/dev/null || true
    rm -f terraform.tfstate*
    rm -f *.tfplan
    rm -rf .terraform/
    rm -rf terraform.tfstate.d/
    echo "✅ Cleaned environments state"
    
    # Clean backend
    cd "$BACKEND_DIR" 2>/dev/null || true
    rm -f terraform.tfstate*
    rm -f *.tfplan
    rm -f backend.*.auto.tfvars
    rm -rf .terraform/
    echo "✅ Cleaned backend state"
    
    # Clean backend configs in environments
    cd "$ENVIRONMENTS_DIR" 2>/dev/null || true
    rm -f backend-*.tf
    echo "✅ Cleaned backend configurations"
    
    # Step 4: Reset LocalStack
    echo "🐳 Step 4: Resetting LocalStack..."
    
    # Stop and remove LocalStack containers
    CONTAINER_NAME="localstack-${ENVIRONMENT}"
    if docker ps -a --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "Stopping and removing LocalStack container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" || true
        docker rm "$CONTAINER_NAME" || true
        echo "✅ LocalStack container removed"
    else
        echo "⚠️  LocalStack container $CONTAINER_NAME not found"
    fi
    
    # Clean up LocalStack data
    LOCALSTACK_DATA_DIR="$SCRIPT_DIR/../../localstack/${ENVIRONMENT}"
    if [ -d "$LOCALSTACK_DATA_DIR" ]; then
        echo "Cleaning LocalStack data directory: $LOCALSTACK_DATA_DIR"
        rm -rf "${LOCALSTACK_DATA_DIR:?}"/* || true
        echo "✅ LocalStack data cleaned"
    else
        echo "⚠️  LocalStack data directory not found"
    fi
    
    echo ""
    echo "=== Clean Reset Completed: $(date) ==="
    echo "🎉 Clean reset complete for environment: $ENVIRONMENT"
    
} 2>&1 | tee "$LOG_FILE"

echo ""
echo "📋 Full log saved to: $LOG_FILE"
echo ""
echo "🚀 To start fresh, run:"
echo "   ./run_localstack_env.sh -e $ENVIRONMENT"
echo "   ./setup_backend.sh -e $ENVIRONMENT"
echo "   cd ../environments && terraform init && terraform plan"