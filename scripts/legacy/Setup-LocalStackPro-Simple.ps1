#!/usr/bin/env pwsh
# Simple LocalStack Pro Connection Setup
# Reads API key from .auto.tfvars files and starts all environments

Write-Host "🚀 Setting up LocalStack Pro Connection" -ForegroundColor Cyan
Write-Host ""

# Function to get LocalStack API key from .auto.tfvars files
function Get-LocalStackApiKey {
    $files = @(
        "environments\develop.auto.tfvars",
        "environments\nonprod.auto.tfvars", 
        "environments\staging.auto.tfvars",
        "environments\prod.auto.tfvars"
    )
    
    foreach ($file in $files) {
        if (Test-Path $file) {
            Write-Host "📄 Checking $file..." -ForegroundColor Yellow
            $content = Get-Content $file -Raw
            
            if ($content -match 'localstack_api_key\s*=\s*"([^"]+)"') {
                Write-Host "✓ Found API key in $file" -ForegroundColor Green
                return $matches[1]
            }
        }
    }
    return $null
}

# Get API key
$ApiKey = Get-LocalStackApiKey

if (-not $ApiKey) {
    Write-Host "❌ Could not find LocalStack API key" -ForegroundColor Red
    Write-Host "Please ensure localstack_api_key is set in your .auto.tfvars files" -ForegroundColor Yellow
    exit 1
}

# Set environment variables
$env:LOCALSTACK_API_KEY = $ApiKey
Write-Host "✓ Set LOCALSTACK_API_KEY for current session" -ForegroundColor Green

# Set permanently
try {
    [Environment]::SetEnvironmentVariable("LOCALSTACK_API_KEY", $ApiKey, "User")
    Write-Host "✓ Set LOCALSTACK_API_KEY permanently" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Could not set permanent environment variable" -ForegroundColor Yellow
}

Write-Host ""

# Stop existing containers
Write-Host "🛑 Stopping existing containers..." -ForegroundColor Yellow
& .\scripts\Manage-Environments.ps1 -Action stop -Environment all

Write-Host ""

# Start all environments
Write-Host "🚀 Starting all LocalStack environments..." -ForegroundColor Yellow
& .\scripts\Manage-Environments.ps1 -Action start -Environment all

Write-Host ""
Write-Host "⏳ Waiting 30 seconds for containers to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "🔍 Checking environment status..." -ForegroundColor Yellow

$environments = @("develop", "nonprod", "staging", "prod")
$ports = @{
    "develop" = 4566
    "nonprod" = 4567
    "staging" = 4568
    "prod" = 4569
}

foreach ($envName in $environments) {
    $port = $ports[$envName]
    Write-Host "Checking $envName (port $port)..." -ForegroundColor White
    
    try {
        $health = Invoke-RestMethod -Uri "http://localhost:$port/_localstack/health" -TimeoutSec 5
        Write-Host "  ✓ $envName online" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ $envName not responding" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📋 LocalStack Cloud Dashboard Endpoints:" -ForegroundColor Cyan
Write-Host "  develop:  http://localhost:4566" -ForegroundColor White
Write-Host "  nonprod:  http://localhost:4567" -ForegroundColor White
Write-Host "  staging:  http://localhost:4568" -ForegroundColor White
Write-Host "  prod:     http://localhost:4569" -ForegroundColor White

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Go to your LocalStack Cloud Dashboard" -ForegroundColor White
Write-Host "2. Add new stacks for 'staging' and 'prod'" -ForegroundColor White
Write-Host "3. Use the endpoints above" -ForegroundColor White
Write-Host "4. All environments should show as 'online'" -ForegroundColor White

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
