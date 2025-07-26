#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generate Terraform module dependency visualizations
.DESCRIPTION
    This script creates interactive visualizations of module dependencies,
    compatibility matrices, and generates analysis reports.
.PARAMETER ModulesDir
    Directory containing Terraform modules
.PARAMETER OutputDir
    Output directory for visualizations
.PARAMETER Format
    Output format: html, json, or all
.EXAMPLE
    .\visualize_dependencies.ps1
.EXAMPLE
    .\visualize_dependencies.ps1 -ModulesDir "../modules" -OutputDir "docs/visualizations" -Format "html"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ModulesDir = "../modules",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "visualizations",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("html", "json", "all")]
    [string]$Format = "all"
)

$ErrorActionPreference = "Stop"

Write-Host "📊 Terraform Module Dependency Visualizer" -ForegroundColor Green

# Check if Python is available
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Python not found. Please install Python first."
    exit 1
}

# Check if required packages are installed
Write-Host "🔍 Checking Python dependencies..." -ForegroundColor Yellow

$requirementsFile = Join-Path $PSScriptRoot "requirements-viz.txt"
if (Test-Path $requirementsFile) {
    Write-Host "📦 Installing required packages..." -ForegroundColor Yellow
    try {
        python -m pip install -r $requirementsFile --quiet
        Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
    } catch {
        Write-Warning "⚠️  Failed to install some dependencies: $($_.Exception.Message)"
        Write-Host "🔧 Try installing manually:" -ForegroundColor Cyan
        Write-Host "   pip install networkx plotly python-hcl2" -ForegroundColor Gray
    }
} else {
    Write-Warning "⚠️  requirements-viz.txt not found, attempting to install packages manually..."
    try {
        python -m pip install networkx plotly python-hcl2 --quiet
        Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
    } catch {
        Write-Warning "⚠️  Failed to install dependencies. Please install manually:"
        Write-Host "   pip install networkx plotly python-hcl2" -ForegroundColor Gray
    }
}

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Host "📁 Created output directory: $OutputDir" -ForegroundColor Cyan
}

# Run the Python visualization script
$pythonScript = Join-Path $PSScriptRoot "visualize_dependencies.py"
if (-not (Test-Path $pythonScript)) {
    Write-Error "❌ Python script not found: $pythonScript"
    exit 1
}

Write-Host "🚀 Running dependency analysis..." -ForegroundColor Green

try {
    $arguments = @(
        $pythonScript,
        "--modules-dir", $ModulesDir,
        "--output-dir", $OutputDir,
        "--format", $Format
    )
    
    python @arguments
    
    Write-Host ""
    Write-Host "🎉 Visualization complete!" -ForegroundColor Green
    Write-Host "📁 Output files saved to: $OutputDir" -ForegroundColor Cyan
    
    # List generated files
    $outputFiles = Get-ChildItem -Path $OutputDir -File
    if ($outputFiles) {
        Write-Host "📄 Generated files:" -ForegroundColor Cyan
        foreach ($file in $outputFiles) {
            Write-Host "   - $($file.Name)" -ForegroundColor Gray
        }
        
        # Try to open HTML files
        if ($Format -in @("html", "all")) {
            $htmlFile = Join-Path $OutputDir "module_dependencies.html"
            if (Test-Path $htmlFile) {
                Write-Host ""
                Write-Host "🌐 Opening dependency graph in browser..." -ForegroundColor Yellow
                try {
                    Start-Process $htmlFile
                } catch {
                    Write-Host "   Or open manually: $htmlFile" -ForegroundColor Gray
                }
            }
        }
    }
    
} catch {
    Write-Error "❌ Failed to generate visualizations: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "🔧 Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "   1. Ensure Python is installed and in PATH" -ForegroundColor Gray
    Write-Host "   2. Install required packages: pip install networkx plotly python-hcl2" -ForegroundColor Gray
    Write-Host "   3. Check that modules directory exists: $ModulesDir" -ForegroundColor Gray
    exit 1
}