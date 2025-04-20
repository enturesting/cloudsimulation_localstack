param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("develop", "nonprod", "feature")]
    [string]$env
)

# Set dummy LocalStack-style credentials for local use
switch ($env) {
    "develop" {
        $env:AWS_ACCESS_KEY_ID = "develop-access"
        $env:AWS_SECRET_ACCESS_KEY = "develop-secret"
        $env:AWS_ACCOUNT_ID = "333333333333"
    }
    "nonprod" {
        $env:AWS_ACCESS_KEY_ID = "nonprod-access"
        $env:AWS_SECRET_ACCESS_KEY = "nonprod-secret"
        $env:AWS_ACCOUNT_ID = "222222222222"
    }
    "feature" {
        $env:AWS_ACCESS_KEY_ID = "develop-access"
        $env:AWS_SECRET_ACCESS_KEY = "develop-secret"
        $env:AWS_ACCOUNT_ID = "333333333333"
    }
}


# Define paths
$envDir = "terraform\environments"
$tfvarsFile = "$envDir\$env.tfvars"
$planFile = ".tfplan"

# Check for main.tf
if (-not (Test-Path "$envDir\main.tf")) {
    Write-Host "Terraform files not found in: $envDir" -ForegroundColor Red
    exit 1
}

# Check for tfvars
if (-not (Test-Path $tfvarsFile)) {
    Write-Host "tfvars file not found: $tfvarsFile" -ForegroundColor Red
    exit 1
}

# Navigate to environment directory
Set-Location $envDir

# Run Terraform init
Write-Host "`nInitializing Terraform for '$env'..." -ForegroundColor Cyan
terraform init

# Run Terraform plan
Write-Host "`nGenerating plan for '$env'..." -ForegroundColor Cyan
terraform plan -var-file="$env.tfvars" -out="$planFile"

# Confirm with user
Write-Host "`nReview the plan above. Do you want to proceed with applying changes? (y/n): " -NoNewline
$response = Read-Host
if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "`nAborting apply operation." -ForegroundColor Yellow
    Remove-Item -Force "$planFile" -ErrorAction SilentlyContinue
    exit 0
}

# Apply the saved plan
Write-Host "`nApplying changes for '$env'..." -ForegroundColor Cyan
terraform apply "$planFile"

# Cleanup
Remove-Item -Force "$planFile" -ErrorAction SilentlyContinue
Write-Host "`nDone!" -ForegroundColor Green
