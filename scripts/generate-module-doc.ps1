<#
.SYNOPSIS
    Generates or displays Terraform module documentation using terraform-docs.

.DESCRIPTION
    - If README.md already exists in the module folder, terraform-docs output is displayed to the terminal.
    - If README.md does not exist, a new README.md is created with a title heading and terraform-docs documentation appended.

.PARAMETER ModulePath
    Path to the Terraform module (e.g., modules/s3).

.EXAMPLE
    .\generate-module-doc.ps1 -ModulePath "modules\s3"

.NOTES
    Requires terraform-docs to be installed and available in PATH.
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Path to the Terraform module folder")]
    [string]$ModulePath
)

function Show-Help {
    Get-Help -Detailed $MyInvocation.MyCommand.Path
    exit
}

# If user runs -help, show help
if ($ModulePath -eq "-help" -or $ModulePath -eq "--help") {
    Show-Help
}

if (-not (Test-Path $ModulePath)) {
    Write-Error "Error: Module path '$ModulePath' does not exist."
    exit 1
}

$ReadmePath = Join-Path $ModulePath "README.md"

# Try running terraform-docs first to verify it's working
try {
    $TerraformDocsOutput = terraform-docs markdown table $ModulePath 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "terraform-docs failed. Output:"
        Write-Host $TerraformDocsOutput
        exit 1
    }
} catch {
    Write-Error "terraform-docs is not installed or not in PATH."
    exit 1
}

# Now check if README exists
if (Test-Path $ReadmePath) {
    Write-Host "ℹREADME.md already exists in $ModulePath. Showing terraform-docs output below:" -ForegroundColor Yellow
    Write-Host "`n================== terraform-docs Output ==================`n"
    Write-Host $TerraformDocsOutput
}
else {
    Write-Host "README.md does not exist. Creating a new one with heading and terraform-docs output..." -ForegroundColor Green

    # Generate title from folder name
    $ModuleName = Split-Path $ModulePath -Leaf
    $Title = "# $ModuleName Module`n"

    # Write title + terraform-docs output
    $Title | Out-File -FilePath $ReadmePath -Encoding utf8
    $TerraformDocsOutput | Out-File -FilePath $ReadmePath -Append -Encoding utf8

    Write-Host ("README.md created at $ReadmePath") -ForegroundColor Green
