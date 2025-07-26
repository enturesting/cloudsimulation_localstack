param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("develop", "nonprod", "feature")]
    [string]$env,
    
    [Parameter(Mandatory = $false)]
    [string]$path = ""
)

# Set working directory to the project root (parent of the scripts directory)
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptRoot
Set-Location $projectRoot

$ErrorActionPreference = "Stop"
$originalLocation = Get-Location

# Define paths
$baseDir = if ($path) { 
    # If path is provided, use it as the base directory
    $fullPath = if ([System.IO.Path]::IsPathRooted($path)) {
        $path
    } else {
        Join-Path (Get-Location) $path
    }
    $fullPath
} else { 
    # Default to environments directory if no path is provided
    Join-Path (Get-Location) "environments" 
}
$tfvarsFile = Join-Path $baseDir "${env}.tfvars"
$secretsFile = Join-Path $baseDir "${env}.auto.tfvars"
$planFile = Join-Path $baseDir ".tfplan"

# Debug output
Write-Host "Using base directory: $baseDir" -ForegroundColor Cyan
Write-Host "Terraform vars file: $tfvarsFile" -ForegroundColor Cyan
Write-Host "Secrets file: $secretsFile" -ForegroundColor Cyan

# Ensure we return to original location on exit
try {
    # Check for required files
    if (-not (Test-Path (Join-Path $baseDir "main.tf"))) {
        Write-Host "Terraform files not found in: $baseDir" -ForegroundColor Red
        exit 1
    }
    if (-not (Test-Path $tfvarsFile)) {
        Write-Host "tfvars file not found: $tfvarsFile" -ForegroundColor Red
        exit 1
    }
    if (-not (Test-Path $secretsFile)) {
        Write-Host "Required secrets file not found: $secretsFile" -ForegroundColor Red
        exit 1
    }

    # Load and validate secrets
    try {
        # Read the secrets file once
        $rawContent = Get-Content $secretsFile -Raw -ErrorAction Stop
        
        # Extract required values
        $accountIdMatch = $rawContent | Select-String -Pattern 'account_id\s*=\s*"(.+?)"'
        $accessKeyMatch = $rawContent | Select-String -Pattern 'access_key\s*=\s*"(.+?)"'
        $secretKeyMatch = $rawContent | Select-String -Pattern 'secret_key\s*=\s*"(.+?)"'

        # Validate all required keys are present
        $missingKeys = @()
        if (-not $accountIdMatch) { $missingKeys += "account_id" }
        if (-not $accessKeyMatch) { $missingKeys += "access_key" }
        if (-not $secretKeyMatch) { $missingKeys += "secret_key" }

        if ($missingKeys.Count -gt 0) {
            Write-Host ("`n Missing required keys in {0}:" -f $secretsFile) -ForegroundColor Red
            $missingKeys | ForEach-Object { Write-Host "  - $_" }
            Write-Host "`nPlease check your secrets file or regenerate from the example."
            exit 1
        }

        # Set environment variables
        $env:AWS_ACCOUNT_ID = $accountIdMatch.Matches[0].Groups[1].Value
        $env:AWS_ACCESS_KEY_ID = $accessKeyMatch.Matches[0].Groups[1].Value
        $env:AWS_SECRET_ACCESS_KEY = $secretKeyMatch.Matches[0].Groups[1].Value

        Write-Host "Successfully loaded AWS credentials" -ForegroundColor Green
    }
    catch {
        Write-Host "`n Error reading or parsing secrets file: $_" -ForegroundColor Red
        exit 1
    }

    # Navigate to environment directory
    Set-Location $baseDir

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
    $planResult = terraform plan -var-file="$tfvarsFile" -out="$planFile"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`nError generating plan. Exiting." -ForegroundColor Red
        exit 1
    }

    # Prompt for apply
    Write-Host ""
    Write-Host "Review the plan above. Do you want to proceed with applying changes? (y/n): "
    $response = Read-Host
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "`nAborting apply operation." -ForegroundColor Yellow
        Remove-Item -Force "$planFile" -ErrorAction SilentlyContinue
        exit 0
    }

    # Terraform apply
    Write-Host "`nApplying changes for '$env'..." -ForegroundColor Cyan
    terraform apply "${planFile}"

    # Cleanup
    Remove-Item -Force "$planFile" -ErrorAction SilentlyContinue
    Write-Host "`nDone!" -ForegroundColor Green
}
catch {
    Write-Host "`nAn error occurred: $_" -ForegroundColor Red
    exit 1
}
finally {
    # Always return to original directory
    Set-Location $originalLocation
}
