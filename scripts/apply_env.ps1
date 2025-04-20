param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("develop", "nonprod", "feature")]
    [string]$env
)

# Define paths
$envDir = "environments"
$tfvarsFile = "$envDir\$env.tfvars"
$secretsFile = "$envDir\$env.auto.tfvars.json"
$planFile = ".tfplan"

# Check for required files
if (-not (Test-Path "$envDir\main.tf")) {
    Write-Host "Terraform files not found in: $envDir" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $tfvarsFile)) {
    Write-Host "tfvars file not found: $tfvarsFile" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $secretsFile)) {
    Write-Host "Required secrets file not found: $secretsFile" -ForegroundColor Red
    Write-Host "You can create it from the example:"
    Write-Host "   cp $env.auto.tfvars.json.example $env.auto.tfvars.json`n"
    exit 1
}

# Load account_id (or any other values) from the secrets file
$secrets = Get-Content $secretsFile | ConvertFrom-Json

# Validate required keys
if (-not $secrets.account_id -or -not $secrets.access_key -or -not $secrets.secret_key) {
    Write-Host "`n Missing required keys in `${secretsFile}`:`n`nExpected keys:" -ForegroundColor Red    Write-Host "  - account_id"
    Write-Host "  - access_key"
    Write-Host "  - secret_key"
    Write-Host "`nPlease check your secrets file or regenerate from the example."
    exit 1
}

# Export credentials to env vars (optional for tools that use them)
$env:AWS_ACCOUNT_ID = $secrets.account_id
$env:AWS_ACCESS_KEY_ID = $secrets.access_key
$env:AWS_SECRET_ACCESS_KEY = $secrets.secret_key

# Navigate to environment directory
Set-Location $envDir

# Terraform init
Write-Host "`nInitializing Terraform for '$env'..." -ForegroundColor Cyan
terraform init

# Terraform plan
Write-Host "`nGenerating plan for '$env'..." -ForegroundColor Cyan
terraform plan -var-file="$env.tfvars" -out="$planFile"

# Prompt for apply
Write-Host "`nReview the plan above. Do you want to proceed with applying changes? (y/n): " -NoNewline
$response = Read-Host
if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "`nAborting apply operation." -ForegroundColor Yellow
    Remove-Item -Force "$planFile" -ErrorAction SilentlyContinue
    exit 0
}

# Terraform apply
Write-Host "`nApplying changes for '$env'..." -ForegroundColor Cyan
terraform apply "$planFile"

# Cleanup
Remove-Item -Force "$planFile" -ErrorAction SilentlyContinue
Write-Host "`nDone!" -ForegroundColor Green
