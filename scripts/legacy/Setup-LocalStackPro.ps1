#!/usr/bin/env pwsh
# Setup LocalStack Pro Connection for Cloud Dashboard
# Automatically reads LocalStack API key from existing .auto.tfvars files

Write-Host "🚀 Setting up LocalStack Pro Connection" -ForegroundColor Cyan
Write-Host ""

# Function to extract LocalStack API key from .auto.tfvars files
function Get-LocalStackApiKey {
    $possibleFiles = @(
        "environments\develop.auto.tfvars",
        "environments\nonprod.auto.tfvars",
        "environments\staging.auto.tfvars",
        "environments\prod.auto.tfvars"
    )
    
    foreach ($file in $possibleFiles) {
        if (Test-Path $file) {
            Write-Host "📄 Reading LocalStack API key from $file..." -ForegroundColor Yellow
            $content = Get-Content $file -Raw
            
            # Look for LOCALSTACK_API_KEY in various formats
            if ($content -match 'LOCALSTACK_API_KEY\s*=\s*"([^"]+)"') {
                return $matches[1]
            }
            if ($content -match 'localstack_api_key\s*=\s*"([^"]+)"') {
                return $matches[1]
            }
            if ($content -match 'api_key\s*=\s*"([^"]+)"') {
                return $matches[1]
            }
        }
    }
    
    return $null
}

# Get API key from existing files
$ApiKey = Get-LocalStackApiKey

if (-not $ApiKey) {
    Write-Host "❌ Could not find LocalStack API key in .auto.tfvars files" -ForegroundColor Red
    Write-Host "Please ensure your API key is set in one of these files:" -ForegroundColor Yellow
    Write-Host "  - environments\develop.auto.tfvars" -ForegroundColor White
    Write-Host "  - environments\nonprod.auto.tfvars" -ForegroundColor White
    Write-Host "" 
    Write-Host "Expected format: LOCALSTACK_API_KEY = \"your-key-here\"" -ForegroundColor White
    exit 1
}

Write-Host "✓ Found LocalStack API key" -ForegroundColor Green

# Set environment variable for current session
$env:LOCALSTACK_API_KEY = $ApiKey
Write-Host "✓ Set LOCALSTACK_API_KEY for current session" -ForegroundColor Green

# Set environment variable permanently
try {
    [Environment]::SetEnvironmentVariable("LOCALSTACK_API_KEY", $ApiKey, "User")
    Write-Host "✓ Set LOCALSTACK_API_KEY permanently for user" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not set permanent environment variable" -ForegroundColor Yellow
}

Write-Host ""

# Stop any running containers
Write-Host "🛑 Stopping existing LocalStack containers..." -ForegroundColor Yellow
.\Manage-Environments.ps1 -Action stop -Environment all

Write-Host ""

# Start containers with Pro API key
Write-Host "🚀 Starting LocalStack containers with Pro API key..." -ForegroundColor Yellow
.\Manage-Environments.ps1 -Action start -Environment all

Write-Host ""

# Wait for containers to start
Write-Host "⏳ Waiting for containers to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check container status
Write-Host "🔍 Checking container status..." -ForegroundColor Yellow
$environments = @("develop", "nonprod", "staging", "prod")
$ports = @{
    "develop" = 4566
    "nonprod" = 4567
    "staging" = 4568
    "prod" = 4569
}

foreach ($env in $environments) {
    $port = $ports[$env]
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$port/_localstack/health" -TimeoutSec 10 -ErrorAction Stop
        Write-Host "✓ $env environment online (port $port)" -ForegroundColor Green
        
        # Check if Pro features are enabled
        if ($response.pro -eq $true) {
            Write-Host "  ✓ LocalStack Pro features enabled" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Pro features not detected" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "✗ $env environment not responding (port $port)" -ForegroundColor Red
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
Write-Host "3. Use the endpoints above for each environment" -ForegroundColor White
Write-Host "4. All environments should now show as 'online'" -ForegroundColor White

Write-Host ""
Write-Host "✅ LocalStack Pro setup complete!" -ForegroundColor Green
