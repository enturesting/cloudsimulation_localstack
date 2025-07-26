#!/usr/bin/env pwsh
# Initialize Multi-Environment LocalStack Setup
# This script sets up the enhanced 4-environment configuration

Write-Host "🚀 Initializing Enhanced Multi-Environment LocalStack Setup" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow

# Check Docker
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "✓ Docker is available" -ForegroundColor Green
}
else {
    Write-Host "✗ Docker is not available or not running" -ForegroundColor Red
    exit 1
}

# Check Terraform
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Write-Host "✓ Terraform is available" -ForegroundColor Green
}
else {
    Write-Host "✗ Terraform is not available" -ForegroundColor Red
    exit 1
}

# Check if we're in the right directory
if (-not (Test-Path "docker-compose.enhanced.yml")) {
    Write-Host "✗ Please run this script from the cloudsimulation_localstack directory" -ForegroundColor Red
    exit 1
}

Write-Host "✓ All prerequisites met" -ForegroundColor Green
Write-Host ""

# Copy configuration files from templates
Write-Host "📁 Setting up configuration files..." -ForegroundColor Yellow

$Environments = @("staging", "prod")
$Regions = @("us-east-1", "us-east-2")

foreach ($env in $Environments) {
    foreach ($region in $Regions) {
        $templatePath = "environments\$env\$region\terraform.tfvars.template"
        $configPath = "environments\$env\$region\terraform.tfvars"
        $mainTfPath = "environments\$env\$region\main.tf"
        
        if (Test-Path $templatePath) {
            if (-not (Test-Path $configPath)) {
                Copy-Item $templatePath $configPath
                Write-Host "✓ Created terraform.tfvars for $env/$region" -ForegroundColor Green
            } else {
                Write-Host "- terraform.tfvars already exists for $env/$region" -ForegroundColor Gray
            }
        }
        
        # Copy main.tf from environments directory
        if ((Test-Path "environments\main.tf") -and (-not (Test-Path $mainTfPath))) {
            Copy-Item "environments\main.tf" $mainTfPath
            Write-Host "✓ Created main.tf for $env/$region" -ForegroundColor Green
        }
    }
}

Write-Host ""

# Start LocalStack environments
Write-Host "🐳 Starting LocalStack environments..." -ForegroundColor Yellow

docker-compose -f docker-compose.enhanced.yml up -d | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ All LocalStack containers started" -ForegroundColor Green
}
else {
    Write-Host "✗ Failed to start LocalStack containers" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⏳ Waiting for environments to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check environment health
Write-Host "🔍 Checking environment health..." -ForegroundColor Yellow

$PortMap = @{
    "develop" = 4566
    "nonprod" = 4567
    "staging" = 4568
    "prod" = 4569
}

$AllHealthy = $true

foreach ($env in @("develop", "nonprod", "staging", "prod")) {
    $port = $PortMap[$env]
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$port/_localstack/health" -TimeoutSec 10 -ErrorAction Stop
        $serviceCount = ($response.services.PSObject.Properties | Measure-Object).Count
        Write-Host "✓ $env environment healthy (port $port) - $serviceCount services" -ForegroundColor Green
    } catch {
        Write-Host "✗ $env environment not responding (port $port)" -ForegroundColor Red
        $AllHealthy = $false
    }
}

Write-Host ""

if ($AllHealthy) {
    Write-Host "🎉 Multi-environment setup completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Deploy to staging: .\scripts\Manage-Environments.ps1 -Action deploy -Environment staging -Region us-east-1" -ForegroundColor White
    Write-Host "2. Test deployment: .\scripts\Manage-Environments.ps1 -Action test -Environment staging" -ForegroundColor White
    Write-Host "3. Check status: .\scripts\Manage-Environments.ps1 -Action status" -ForegroundColor White
    Write-Host ""
    Write-Host "Available environments:" -ForegroundColor Cyan
    Write-Host "- develop (port 4566)" -ForegroundColor White
    Write-Host "- nonprod (port 4567)" -ForegroundColor White
    Write-Host "- staging (port 4568)" -ForegroundColor White
    Write-Host "- prod (port 4569)" -ForegroundColor White
} else {
    Write-Host "⚠️  Some environments are not healthy. Check Docker logs:" -ForegroundColor Yellow
    Write-Host "docker logs localstack-staging" -ForegroundColor White
    Write-Host "docker logs localstack-prod" -ForegroundColor White
}

Write-Host ""
Write-Host "📚 For more commands, run: .\scripts\Manage-Environments.ps1 -Action status" -ForegroundColor Cyan
