#!/usr/bin/env pwsh
# Enhanced LocalStack Pro Environment Management Script
# Uses the working manual Docker approach for reliable Pro connectivity

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "restart", "status", "cleanup", "health")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "develop", "nonprod", "staging", "prod")]
    [string]$Environment = "all"
)

# Environment configuration
$Environments = @{
    "develop" = @{
        Name = "localstack-develop"
        Port = "4566:4566"
        AccessKey = "develop-key"
        SecretKey = "develop-secret"
    }
    "nonprod" = @{
        Name = "localstack-nonprod"
        Port = "4567:4566"
        AccessKey = "nonprod-key"
        SecretKey = "nonprod-secret"
    }
    "staging" = @{
        Name = "localstack-staging"
        Port = "4568:4566"
        AccessKey = "staging-key"
        SecretKey = "staging-secret"
    }
    "prod" = @{
        Name = "localstack-prod"
        Port = "4569:4566"
        AccessKey = "prod-key"
        SecretKey = "prod-secret"
    }
}

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
            $content = Get-Content $file -Raw
            if ($content -match 'localstack_api_key\s*=\s*"([^"]+)"') {
                return $matches[1]
            }
        }
    }
    return $null
}

# Function to start a LocalStack environment
function Start-LocalStackEnvironment {
    param($EnvName, $Config)
    
    Write-Host "🚀 Starting $EnvName environment..." -ForegroundColor Yellow
    
    # Check if container already exists
    $existing = docker ps -a --filter "name=$($Config.Name)" --format "{{.Names}}"
    if ($existing) {
        Write-Host "  Container $($Config.Name) already exists. Removing..." -ForegroundColor Yellow
        docker rm -f $Config.Name | Out-Null
    }
    
    # Start the container
    $containerId = docker run -d --name $Config.Name -p $Config.Port `
        -e LOCALSTACK_API_KEY=$env:LOCALSTACK_API_KEY `
        -e DEBUG=1 `
        -e AWS_ACCESS_KEY_ID=$Config.AccessKey `
        -e AWS_SECRET_ACCESS_KEY=$Config.SecretKey `
        -e SERVICES=s3,dynamodb,lambda,apigateway,iam,kms,ec2,sts `
        -e PERSISTENCE=1 `
        localstack/localstack-pro:latest
    
    if ($containerId) {
        Write-Host "  ✓ $EnvName started successfully" -ForegroundColor Green
        Write-Host "    Container ID: $($containerId.Substring(0,12))..." -ForegroundColor Gray
        Write-Host "    Endpoint: http://localhost:$($Config.Port.Split(':')[0])" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ Failed to start $EnvName" -ForegroundColor Red
    }
}

# Function to stop a LocalStack environment
function Stop-LocalStackEnvironment {
    param($EnvName, $Config)
    
    Write-Host "🛑 Stopping $EnvName environment..." -ForegroundColor Yellow
    
    $result = docker rm -f $Config.Name 2>$null
    if ($result) {
        Write-Host "  ✓ $EnvName stopped successfully" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  $EnvName was not running" -ForegroundColor Yellow
    }
}

# Function to check environment status
function Get-EnvironmentStatus {
    param($EnvName, $Config)
    
    $status = docker ps --filter "name=$($Config.Name)" --format "{{.Status}}"
    $port = $Config.Port.Split(':')[0]
    
    if ($status) {
        Write-Host "  ✓ $EnvName - $status" -ForegroundColor Green
        Write-Host "    Endpoint: http://localhost:$port" -ForegroundColor Gray
        
        # Test health endpoint
        try {
            $health = Invoke-RestMethod -Uri "http://localhost:$port/_localstack/health" -TimeoutSec 3
            Write-Host "    Health: Online" -ForegroundColor Green
        } catch {
            Write-Host "    Health: Starting up..." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ✗ $EnvName - Not running" -ForegroundColor Red
    }
}

# Function to perform Docker cleanup
function Invoke-DockerCleanup {
    Write-Host "🧹 Docker Cleanup Options:" -ForegroundColor Cyan
    Write-Host "This will help clean up Docker resources that might interfere with LocalStack." -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Remove all stopped LocalStack containers? (y/N)"
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        Write-Host "Removing stopped LocalStack containers..." -ForegroundColor Yellow
        docker container prune --filter "label=name=localstack*" -f
        Write-Host "✓ Cleanup complete" -ForegroundColor Green
    }
    
    Write-Host ""
    $choice = Read-Host "Remove unused Docker networks? (y/N)"
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        Write-Host "Removing unused networks..." -ForegroundColor Yellow
        docker network prune -f
        Write-Host "✓ Network cleanup complete" -ForegroundColor Green
    }
    
    Write-Host ""
    $choice = Read-Host "Remove unused Docker volumes? (y/N)"
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        Write-Host "Removing unused volumes..." -ForegroundColor Yellow
        docker volume prune -f
        Write-Host "✓ Volume cleanup complete" -ForegroundColor Green
    }
}

# Main script logic
Write-Host "🔧 LocalStack Pro Environment Manager" -ForegroundColor Cyan
Write-Host "Action: $Action | Environment: $Environment" -ForegroundColor White
Write-Host ""

# Get API key
if ($Action -ne "cleanup" -and $Action -ne "status") {
    $ApiKey = Get-LocalStackApiKey
    if (-not $ApiKey) {
        Write-Host "❌ Could not find LocalStack API key in .auto.tfvars files" -ForegroundColor Red
        exit 1
    }
    $env:LOCALSTACK_API_KEY = $ApiKey
    Write-Host "✓ Found LocalStack Pro API key" -ForegroundColor Green
    Write-Host ""
}

# Execute action
switch ($Action) {
    "start" {
        if ($Environment -eq "all") {
            foreach ($env in $Environments.Keys) {
                Start-LocalStackEnvironment $env $Environments[$env]
            }
        } else {
            Start-LocalStackEnvironment $Environment $Environments[$Environment]
        }
        
        Write-Host ""
        Write-Host "⏳ Waiting 15 seconds for containers to initialize..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
        
        Write-Host ""
        Write-Host "📋 Environment Status:" -ForegroundColor Cyan
        if ($Environment -eq "all") {
            foreach ($env in $Environments.Keys) {
                Get-EnvironmentStatus $env $Environments[$env]
            }
        } else {
            Get-EnvironmentStatus $Environment $Environments[$Environment]
        }
    }
    
    "stop" {
        if ($Environment -eq "all") {
            foreach ($env in $Environments.Keys) {
                Stop-LocalStackEnvironment $env $Environments[$env]
            }
        } else {
            Stop-LocalStackEnvironment $Environment $Environments[$Environment]
        }
    }
    
    "restart" {
        Write-Host "🔄 Restarting $Environment environment(s)..." -ForegroundColor Yellow
        
        # Stop first
        if ($Environment -eq "all") {
            foreach ($env in $Environments.Keys) {
                Stop-LocalStackEnvironment $env $Environments[$env]
            }
        } else {
            Stop-LocalStackEnvironment $Environment $Environments[$Environment]
        }
        
        Start-Sleep -Seconds 2
        
        # Then start
        if ($Environment -eq "all") {
            foreach ($env in $Environments.Keys) {
                Start-LocalStackEnvironment $env $Environments[$env]
            }
        } else {
            Start-LocalStackEnvironment $Environment $Environments[$Environment]
        }
    }
    
    "status" {
        Write-Host "📋 LocalStack Environment Status:" -ForegroundColor Cyan
        Write-Host ""
        
        if ($Environment -eq "all") {
            foreach ($env in $Environments.Keys) {
                Get-EnvironmentStatus $env $Environments[$env]
                Write-Host ""
            }
        } else {
            Get-EnvironmentStatus $Environment $Environments[$Environment]
        }
    }
    
    "cleanup" {
        Invoke-DockerCleanup
    }
    
    "health" {
        Write-Host "🏥 Health Check for $Environment:" -ForegroundColor Cyan
        Write-Host ""
        
        if ($Environment -eq "all") {
            foreach ($env in $Environments.Keys) {
                $port = $Environments[$env].Port.Split(':')[0]
                Write-Host "Testing $env (port $port)..." -ForegroundColor White
                try {
                    $health = Invoke-RestMethod -Uri "http://localhost:$port/_localstack/health" -TimeoutSec 5
                    Write-Host "  ✓ Online and healthy" -ForegroundColor Green
                    if ($health.pro) {
                        Write-Host "  ✓ LocalStack Pro features enabled" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "  ✗ Not responding" -ForegroundColor Red
                }
                Write-Host ""
            }
        } else {
            $port = $Environments[$Environment].Port.Split(':')[0]
            try {
                $health = Invoke-RestMethod -Uri "http://localhost:$port/_localstack/health" -TimeoutSec 5
                Write-Host "✓ $Environment is online and healthy" -ForegroundColor Green
                if ($health.pro) {
                    Write-Host "✓ LocalStack Pro features enabled" -ForegroundColor Green
                }
            } catch {
                Write-Host "✗ $Environment is not responding" -ForegroundColor Red
            }
        }
    }
}

Write-Host ""
Write-Host "📋 Quick Reference:" -ForegroundColor Cyan
Write-Host "  LocalStack Cloud Dashboard: https://app.localstack.cloud/instances" -ForegroundColor White
Write-Host "  Endpoints:" -ForegroundColor White
Write-Host "    develop:  http://localhost:4566" -ForegroundColor Gray
Write-Host "    nonprod:  http://localhost:4567" -ForegroundColor Gray
Write-Host "    staging:  http://localhost:4568" -ForegroundColor Gray
Write-Host "    prod:     http://localhost:4569" -ForegroundColor Gray

Write-Host ""
Write-Host "✅ Operation complete!" -ForegroundColor Green
