#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Terraform Security Scanner - PowerShell wrapper
.DESCRIPTION
    This script runs automated security analysis on Terraform modules,
    detecting misconfigurations, exposed secrets, and compliance violations.
.PARAMETER ModulesDir
    Directory containing Terraform modules
.PARAMETER OutputDir  
    Output directory for security reports
.PARAMETER Format
    Output format: json, html, sarif, or all
.PARAMETER RunExternal
    Run external scanners (tfsec, checkov) if available
.EXAMPLE
    .\security_scan.ps1
.EXAMPLE
    .\security_scan.ps1 -ModulesDir "../modules" -OutputDir "security_reports" -Format "html"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ModulesDir = "../modules",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "security_reports",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("json", "html", "sarif", "all")]
    [string]$Format = "all",
    
    [Parameter(Mandatory=$false)]
    [switch]$RunExternal
)

$ErrorActionPreference = "Stop"

Write-Host "🔒 Terraform Security Scanner" -ForegroundColor Red
Write-Host "==============================" -ForegroundColor Red

# Check if Python is available
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Python not found. Please install Python first."
    exit 1
}

# Check if required packages are installed
Write-Host "🔍 Checking Python dependencies..." -ForegroundColor Yellow

$requiredPackages = @("python-hcl2")
foreach ($package in $requiredPackages) {
    try {
        python -c "import $(if ($package -eq 'python-hcl2') { 'hcl2' } else { $package })" 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "📦 Installing $package..." -ForegroundColor Yellow
            python -m pip install $package --quiet
        }
    } catch {
        Write-Warning "⚠️  Failed to install $package. Some features may not work."
    }
}

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Host "📁 Created output directory: $OutputDir" -ForegroundColor Cyan
}

# Check for external security tools
$externalTools = @()

if (Get-Command tfsec -ErrorAction SilentlyContinue) {
    $externalTools += "tfsec"
    Write-Host "✅ Found tfsec" -ForegroundColor Green
}

if (Get-Command checkov -ErrorAction SilentlyContinue) {
    $externalTools += "checkov"
    Write-Host "✅ Found checkov" -ForegroundColor Green
}

if (Get-Command terrascan -ErrorAction SilentlyContinue) {
    $externalTools += "terrascan"
    Write-Host "✅ Found terrascan" -ForegroundColor Green
}

if ($externalTools.Count -eq 0 -and $RunExternal) {
    Write-Warning "⚠️ No external security scanners found. Consider installing:"
    Write-Host "   - tfsec: https://github.com/aquasecurity/tfsec" -ForegroundColor Gray
    Write-Host "   - checkov: pip install checkov" -ForegroundColor Gray
    Write-Host "   - terrascan: https://github.com/tenable/terrascan" -ForegroundColor Gray
}

# Run the Python security scanner
$pythonScript = Join-Path $PSScriptRoot "security_scan.py"
if (-not (Test-Path $pythonScript)) {
    Write-Error "❌ Python scanner script not found: $pythonScript"
    exit 1
}

Write-Host ""
Write-Host "🚀 Running security analysis..." -ForegroundColor Green

try {
    $arguments = @(
        $pythonScript,
        "--modules-dir", $ModulesDir,
        "--output-dir", $OutputDir,
        "--format", $Format
    )
    
    if ($RunExternal) {
        $arguments += "--external"
    }
    
    $result = python @arguments
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 Security scan completed successfully!" -ForegroundColor Green
        
        # List generated reports
        $reports = Get-ChildItem -Path $OutputDir -Filter "*.json", "*.html", "*.sarif"
        if ($reports) {
            Write-Host "📄 Generated reports:" -ForegroundColor Cyan
            foreach ($report in $reports) {
                Write-Host "   - $($report.Name)" -ForegroundColor Gray
                
                # Show file size
                $size = [math]::Round($report.Length / 1KB, 1)
                Write-Host "     ($size KB)" -ForegroundColor DarkGray
            }
        }
        
        # Try to open HTML report if generated
        if ($Format -in @("html", "all")) {
            $htmlReport = Join-Path $OutputDir "security_report.html"
            if (Test-Path $htmlReport) {
                Write-Host ""
                Write-Host "🌐 Opening security report in browser..." -ForegroundColor Yellow
                try {
                    Start-Process $htmlReport
                } catch {
                    Write-Host "   Or open manually: $htmlReport" -ForegroundColor Gray
                }
            }
        }
        
        # Run external tools if requested and available
        if ($RunExternal -and $externalTools.Count -gt 0) {
            Write-Host ""
            Write-Host "🔍 Running external security scanners..." -ForegroundColor Yellow
            
            foreach ($tool in $externalTools) {
                Write-Host "   🔧 Running $tool..." -ForegroundColor Cyan
                
                try {
                    switch ($tool) {
                        "tfsec" {
                            $tfsecOutput = Join-Path $OutputDir "tfsec_results.json"
                            tfsec $ModulesDir --format json --out $tfsecOutput
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "     ✅ tfsec results: $tfsecOutput" -ForegroundColor Green
                            }
                        }
                        "checkov" {
                            $checkovOutput = Join-Path $OutputDir "checkov_results.json"
                            checkov -d $ModulesDir --output json --output-file $checkovOutput
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "     ✅ checkov results: $checkovOutput" -ForegroundColor Green
                            }
                        }
                        "terrascan" {
                            $terrascanOutput = Join-Path $OutputDir "terrascan_results.json"
                            terrascan scan -i terraform -d $ModulesDir -o json --output-file $terrascanOutput
                            if ($LASTEXITCODE -eq 0) {
                                Write-Host "     ✅ terrascan results: $terrascanOutput" -ForegroundColor Green
                            }
                        }
                    }
                } catch {
                    Write-Warning "     ⚠️ $tool scan failed: $($_.Exception.Message)"
                }
            }
        }
        
    } else {
        Write-Error "❌ Security scan failed with exit code: $LASTEXITCODE"
    }
    
} catch {
    Write-Error "❌ Failed to run security scan: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "🔧 Troubleshooting tips:" -ForegroundColor Yellow
    Write-Host "   1. Ensure Python is installed and in PATH" -ForegroundColor Gray
    Write-Host "   2. Install required packages: pip install python-hcl2" -ForegroundColor Gray
    Write-Host "   3. Check that modules directory exists: $ModulesDir" -ForegroundColor Gray
    Write-Host "   4. Ensure proper file permissions" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "📋 Security scan summary saved to: $OutputDir" -ForegroundColor Cyan
Write-Host "🔒 Review the findings and implement recommended fixes" -ForegroundColor Yellow