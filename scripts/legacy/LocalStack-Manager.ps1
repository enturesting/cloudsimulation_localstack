#!/usr/bin/env pwsh
# Simple LocalStack Pro Environment Manager

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "restart", "status", "cleanup")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "develop", "nonprod", "staging", "prod")]
    [string]$Environment = "all"
)

Write-Host "🔧 LocalStack Pro Manager" -ForegroundColor Cyan
Write-Host "Action: $Action | Environment: $Environment" -ForegroundColor White
Write-Host ""

# Get API key from tfvars
function Get-ApiKey {
    $files = @("environments\develop.auto.tfvars", "environments\nonprod.auto.tfvars")
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

# Environment configs
$envs = @{
    develop = @{ name = "localstack-develop"; port = "4566:4566"; key = "develop-key"; secret = "develop-secret" }
    nonprod = @{ name = "localstack-nonprod"; port = "4567:4566"; key = "nonprod-key"; secret = "nonprod-secret" }
    staging = @{ name = "localstack-staging"; port = "4568:4566"; key = "staging-key"; secret = "staging-secret" }
    prod = @{ name = "localstack-prod"; port = "4569:4566"; key = "prod-key"; secret = "prod-secret" }
}

# Start environment
function Start-Env($envName) {
    $config = $envs[$envName]
    Write-Host "🚀 Starting $envName..." -ForegroundColor Yellow
    
    docker rm -f $config.name 2>$null | Out-Null
    
    $cmd = "docker run -d --name $($config.name) -p $($config.port) -e LOCALSTACK_API_KEY=$env:LOCALSTACK_API_KEY -e DEBUG=1 -e AWS_ACCESS_KEY_ID=$($config.key) -e AWS_SECRET_ACCESS_KEY=$($config.secret) localstack/localstack-pro:latest"
    
    $result = Invoke-Expression $cmd
    if ($result) {
        Write-Host "  ✓ $envName started" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Failed to start $envName" -ForegroundColor Red
    }
}

# Stop environment
function Stop-Env($envName) {
    $config = $envs[$envName]
    Write-Host "🛑 Stopping $envName..." -ForegroundColor Yellow
    
    $result = docker rm -f $config.name 2>$null
    if ($result) {
        Write-Host "  ✓ $envName stopped" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️ $envName was not running" -ForegroundColor Yellow
    }
}

# Check status
function Get-EnvStatus($envName) {
    $config = $envs[$envName]
    $status = docker ps --filter "name=$($config.name)" --format "{{.Status}}"
    $port = $config.port.Split(':')[0]
    
    if ($status) {
        Write-Host "  ✓ $envName - Running (port $port)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $envName - Not running" -ForegroundColor Red
    }
}

# Get API key if needed
if ($Action -ne "status" -and $Action -ne "cleanup") {
    $apiKey = Get-ApiKey
    if (-not $apiKey) {
        Write-Host "❌ Could not find API key in .auto.tfvars files" -ForegroundColor Red
        exit 1
    }
    $env:LOCALSTACK_API_KEY = $apiKey
    Write-Host "✓ Found API key" -ForegroundColor Green
    Write-Host ""
}

# Execute action
switch ($Action) {
    "start" {
        if ($Environment -eq "all") {
            foreach ($env in $envs.Keys) { Start-Env $env }
        } else {
            Start-Env $Environment
        }
        
        Write-Host ""
        Write-Host "⏳ Waiting 15 seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 15
        
        Write-Host ""
        Write-Host "📋 Status:" -ForegroundColor Cyan
        if ($Environment -eq "all") {
            foreach ($env in $envs.Keys) { Get-EnvStatus $env }
        } else {
            Get-EnvStatus $Environment
        }
    }
    
    "stop" {
        if ($Environment -eq "all") {
            foreach ($env in $envs.Keys) { Stop-Env $env }
        } else {
            Stop-Env $Environment
        }
    }
    
    "restart" {
        if ($Environment -eq "all") {
            foreach ($env in $envs.Keys) { Stop-Env $env }
            Start-Sleep -Seconds 2
            foreach ($env in $envs.Keys) { Start-Env $env }
        } else {
            Stop-Env $Environment
            Start-Sleep -Seconds 2
            Start-Env $Environment
        }
    }
    
    "status" {
        Write-Host "📋 Environment Status:" -ForegroundColor Cyan
        if ($Environment -eq "all") {
            foreach ($env in $envs.Keys) { Get-EnvStatus $env }
        } else {
            Get-EnvStatus $Environment
        }
    }
    
    "cleanup" {
        Write-Host "🧹 Docker Cleanup" -ForegroundColor Cyan
        $choice = Read-Host "Remove stopped containers? (y/N)"
        if ($choice -eq 'y' -or $choice -eq 'Y') {
            docker container prune -f
            Write-Host "✓ Cleanup complete" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "📋 Endpoints:" -ForegroundColor Cyan
Write-Host "  develop:  http://localhost:4566" -ForegroundColor Gray
Write-Host "  nonprod:  http://localhost:4567" -ForegroundColor Gray
Write-Host "  staging:  http://localhost:4568" -ForegroundColor Gray
Write-Host "  prod:     http://localhost:4569" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Complete!" -ForegroundColor Green
