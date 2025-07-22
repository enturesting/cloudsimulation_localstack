#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generate terraform-docs for all modules
.DESCRIPTION
    This script uses terraform-docs to generate consistent documentation for all modules
.PARAMETER ModuleDir
    Directory containing modules (defaults to ../modules)
.EXAMPLE
    .\generate_docs.ps1
.EXAMPLE
    .\generate_docs.ps1 -ModuleDir "../modules"
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$ModuleDir = "../modules"
)

# Check if terraform-docs is installed
if (-not (Get-Command terraform-docs -ErrorAction SilentlyContinue)) {
    Write-Error "terraform-docs not found. Please install it first:"
    Write-Error "  Windows: choco install terraform-docs"
    Write-Error "  Or download from: https://github.com/terraform-docs/terraform-docs/releases"
    exit 1
}

Write-Host "🔍 Discovering module directories..." -ForegroundColor Green

# Get all module directories with versions
$moduleTypes = Get-ChildItem -Path $ModuleDir -Directory
$totalModules = 0

foreach ($moduleType in $moduleTypes) {
    Write-Host "📦 Processing module type: $($moduleType.Name)" -ForegroundColor Cyan
    
    # Get version directories
    $versionDirs = Get-ChildItem -Path $moduleType.FullName -Directory | Where-Object { $_.Name -match "^v\d+\.\d+\.\d+" }
    
    foreach ($versionDir in $versionDirs) {
        $moduleDir = $versionDir.FullName
        Write-Host "  📝 Generating docs for: $($moduleType.Name)/$($versionDir.Name)" -ForegroundColor Yellow
        
        try {
            # Check if module has terraform files
            $tfFiles = Get-ChildItem -Path $moduleDir -Filter "*.tf" -File
            if ($tfFiles.Count -eq 0) {
                Write-Warning "  ⚠️ No .tf files found in $moduleDir, skipping"
                continue
            }
            
            # Create header file if it doesn't exist
            $headerPath = Join-Path $moduleDir "header.md"
            if (-not (Test-Path $headerPath)) {
                @"
# $($moduleType.Name.ToUpper()) Module

Version: $($versionDir.Name)

This module provisions $($moduleType.Name) resources on AWS using LocalStack for local development.
"@ | Out-File -FilePath $headerPath -Encoding UTF8
            }
            
            # Create footer file if it doesn't exist
            $footerPath = Join-Path $moduleDir "footer.md"
            if (-not (Test-Path $footerPath)) {
                @"

## Contributing

1. Update the module code
2. Run tests: ``pytest test/python/$($moduleType.Name)_test.py``
3. Generate docs: ``.\scripts\generate_docs.ps1``
4. Create a new version if needed: ``.\scripts\bump_module_version.ps1``

## License

This module is part of the cloudsimulation_localstack project.
"@ | Out-File -FilePath $footerPath -Encoding UTF8
            }
            
            # Generate documentation
            $configPath = Join-Path $PSScriptRoot "../.terraform-docs.yml"
            Push-Location $moduleDir
            try {
                terraform-docs -c $configPath .
                Write-Host "  ✅ Documentation generated successfully" -ForegroundColor Green
                $totalModules++
            } catch {
                Write-Error "  ❌ Failed to generate docs: $($_.Exception.Message)"
            } finally {
                Pop-Location
            }
            
        } catch {
            Write-Error "  ❌ Error processing $moduleDir`: $($_.Exception.Message)"
        }
    }
}

Write-Host ""
Write-Host "🎉 Documentation generation complete! Updated $totalModules modules." -ForegroundColor Green
Write-Host "📚 Don't forget to run sync_all_docsify_readmes.ps1 to update the docs site." -ForegroundColor Cyan