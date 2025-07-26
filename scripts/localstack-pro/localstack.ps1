#!/usr/bin/env pwsh
# Main LocalStack Pro Environment Manager Entry Point
# Provides easy access to all LocalStack Pro management functions

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "status", "cleanup", "help")]
    [string]$Action = "help"
)

$ScriptDir = $PSScriptRoot

Write-Host "🔧 LocalStack Pro Environment Manager" -ForegroundColor Cyan
Write-Host ""

switch ($Action) {
    "start" {
        Write-Host "Starting all LocalStack Pro environments..." -ForegroundColor Yellow
        & "$ScriptDir\start-all.ps1"
    }
    
    "stop" {
        Write-Host "Stopping all LocalStack Pro environments..." -ForegroundColor Yellow
        & "$ScriptDir\stop-all.ps1"
    }
    
    "status" {
        & "$ScriptDir\status.ps1"
    }
    
    "cleanup" {
        & "$ScriptDir\cleanup.ps1"
    }
    
    "help" {
        Write-Host "📋 Available Commands:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  start    - Start all 4 LocalStack Pro environments" -ForegroundColor White
        Write-Host "  stop     - Stop all LocalStack Pro environments" -ForegroundColor White
        Write-Host "  status   - Check status of all environments" -ForegroundColor White
        Write-Host "  cleanup  - Interactive Docker cleanup (with y/n prompts)" -ForegroundColor White
        Write-Host "  help     - Show this help message" -ForegroundColor White
        Write-Host ""
        Write-Host "📋 Examples:" -ForegroundColor Cyan
        Write-Host "  .\localstack.ps1 start" -ForegroundColor Gray
        Write-Host "  .\localstack.ps1 status" -ForegroundColor Gray
        Write-Host "  .\localstack.ps1 cleanup" -ForegroundColor Gray
        Write-Host ""
        Write-Host "🌐 LocalStack Cloud Dashboard:" -ForegroundColor Cyan
        Write-Host "  https://app.localstack.cloud/instances" -ForegroundColor White
        Write-Host ""
        Write-Host "📋 Environment Endpoints:" -ForegroundColor Cyan
        Write-Host "  develop:  http://localhost:4566" -ForegroundColor Gray
        Write-Host "  nonprod:  http://localhost:4567" -ForegroundColor Gray
        Write-Host "  staging:  http://localhost:4568" -ForegroundColor Gray
        Write-Host "  prod:     http://localhost:4569" -ForegroundColor Gray
    }
    
    default {
        Write-Host "❌ Unknown action: $Action" -ForegroundColor Red
        Write-Host "Run '.\localstack.ps1 help' for available commands" -ForegroundColor Yellow
    }
}

Write-Host ""
