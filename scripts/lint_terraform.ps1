<#
.SYNOPSIS
  Runs Terraform hygiene, lint, and metadata checks.

.DESCRIPTION
  Formats, validates, shows providers, graph, output values, and current state.
  Includes TFLint if installed. Targets 'develop' and 'nonprod'.
#>

$TerraformDir = "environments"
$ChdirFlag = "-chdir=$TerraformDir"

if (-Not (Test-Path $TerraformDir)) {
    Write-Error "Terraform directory '$TerraformDir' does not exist."
    exit 1
}

Write-Host "`nRunning Terraform hygiene and validation..." -ForegroundColor Cyan

# Format .tf files recursively
Write-Host "`nFormatting Terraform code..." -ForegroundColor Yellow
terraform $ChdirFlag fmt -recursive

# Initialize and upgrade modules/providers
Write-Host "`nInitializing Terraform (with upgrade)..." -ForegroundColor Yellow
terraform $ChdirFlag init -upgrade

# Validate syntax and config
Write-Host "`nValidating Terraform configuration..." -ForegroundColor Yellow
terraform $ChdirFlag validate

# Print provider versions
Write-Host "`nDisplaying Terraform providers..." -ForegroundColor Yellow
terraform $ChdirFlag providers

# Generate graph output (basic)
Write-Host "`nGenerating Terraform dependency graph (text output)..." -ForegroundColor Yellow
terraform $ChdirFlag graph

# Run TFLint if available
if (Get-Command "tflint" -ErrorAction SilentlyContinue) {
    Write-Host "`nInitializing TFLint..." -ForegroundColor Yellow
    tflint --init

    Write-Host "`nRunning TFLint..." -ForegroundColor Yellow
    tflint
} else {
    Write-Host "`nTFLint not found. Skipping TFLint checks." -ForegroundColor DarkGray
}

# Environments to check
$envs = @("develop", "nonprod")

foreach ($env in $envs) {
    $tfvars     = "$TerraformDir/$env.tfvars"
    $autovars   = "$TerraformDir/$env.auto.tfvars"

    if (-Not (Test-Path $tfvars)) {
        Write-Warning "Missing file: $tfvars"
        continue
    }
    if (-Not (Test-Path $autovars)) {
        Write-Warning "Missing file: $autovars"
        continue
    }

    Write-Host "`nRunning plan for environment '$env'..." -ForegroundColor Yellow
    terraform $ChdirFlag plan -var-file="$env.tfvars" -var-file="$env.auto.tfvars"

    Write-Host "`nShowing output values for '$env' (if available)..." -ForegroundColor Yellow
    terraform $ChdirFlag output -json | Out-String | Write-Host

    Write-Host "`nShowing current Terraform state for '$env'..." -ForegroundColor Yellow
    terraform $ChdirFlag show -no-color
}

Write-Host "`nAll Terraform hygiene checks completed." -ForegroundColor Green
