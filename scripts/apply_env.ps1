param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("develop", "nonprod", "feature")]
    [string]$env
)

$originalLocation = Get-Location

# Define paths
$envDir = "environments"
$tfvarsFile = "$envDir\$env.tfvars"
$secretsFile = "$envDir\$env.auto.tfvars"
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
    Write-Host "   cp example.auto.tfvars.template $env.auto.tfvars`n"
    exit 1
}

# # Load account_id (or any other values) from the secrets file
$rawContent = Get-Content $secretsFile -Raw

$accountIdMatch = $rawContent | Select-String -Pattern 'account_id\s*=\s*"(.+?)"'
$accessKeyMatch = $rawContent | Select-String -Pattern 'access_key\s*=\s*"(.+?)"'
$secretKeyMatch = $rawContent | Select-String -Pattern 'secret_key\s*=\s*"(.+?)"'

if (-not $accountIdMatch -or -not $accessKeyMatch -or -not $secretKeyMatch) {
    Write-Host "`n Missing required keys in `${secretsFile}`:`n`nExpected keys:" -ForegroundColor Red
    Write-Host "  - account_id"
    Write-Host "  - access_key"
    Write-Host "  - secret_key"
    Write-Host "`nPlease check your secrets file or regenerate from the example."
    exit 1
}

$env:AWS_ACCOUNT_ID = $accountIdMatch.Matches[0].Groups[1].Value
$env:AWS_ACCESS_KEY_ID = $accessKeyMatch.Matches[0].Groups[1].Value
$env:AWS_SECRET_ACCESS_KEY = $secretKeyMatch.Matches[0].Groups[1].Value

# Navigate to environment directory
Set-Location $envDir

# Terraform init
Write-Host "`nInitializing Terraform for '$env'..." -ForegroundColor Cyan
terraform init

# Switch to workspace if needed
$current = terraform workspace show
if ($current -ne $env) {
    Write-Host "`nSwitching to workspace '$env'" -ForegroundColor Cyan
    $workspaceList = terraform workspace list
    if ($workspaceList -match "\b$env\b") {
        terraform workspace select $env
    } else {
        terraform workspace new $env
    }
}


# Terraform plan
Write-Host "`nGenerating plan for '$env'..." -ForegroundColor Cyan
terraform plan -var-file="$env.tfvars" -out="$planFile"

# Prompt for apply
Write-Host "`nReview the plan above. Do you want to proceed with applying changes? (y/n): " -NoNewline
$response = Read-Host
if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "`nAborting apply operation." -ForegroundColor Yellow
    Remove-Item -Force "$planFile" -ErrorAction SilentlyContinue
    Set-Location $originalLocation
    exit 0
}

# Terraform apply
Write-Host "`nApplying changes for '$env'..." -ForegroundColor Cyan
terraform apply "$planFile"

# Cleanup
Remove-Item -Force "$planFile" -ErrorAction SilentlyContinue
Write-Host "`nDone!" -ForegroundColor Green

# Return to original directory
Set-Location $originalLocation
Write-Host "`nDone! Returned to root: $originalLocation" -ForegroundColor Green