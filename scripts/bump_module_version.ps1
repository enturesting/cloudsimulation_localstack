param(
    [string]$FromVersion = "v0.1.0",
    [string]$ToVersion,
    [string]$Module
)

function Show-Help {
    Write-Host "Usage: .\bump_module_version.ps1 -FromVersion v0.1.0 -ToVersion v0.2.0 [-Module lambda]"
    Write-Host "-FromVersion: The version to copy from (default: v0.1.0)"
    Write-Host "-ToVersion:   The new version to create (required)"
    Write-Host "-Module:      (Optional) Only bump a single module (e.g. lambda, iam, etc)"
    exit 1
}

if (-not $ToVersion) { Show-Help }

$allModules = @("lambda", "api_gateway", "iam", "dynamodb", "vpc", "s3", "kms", "ec2")
$modules = if ($Module) { @($Module) } else { $allModules }

foreach ($mod in $modules) {
    $src = "modules/$mod/$FromVersion"
    $dst = "modules/$mod/$ToVersion"
    if (Test-Path $src) {
        Copy-Item $src $dst -Recurse -Force
        Write-Host "Copied $src to $dst"
        # Auto-update version numbers in README.md, version.tf, and main.tf if present
        $filesToUpdate = @("README.md", "version.tf", "main.tf")
        foreach ($file in $filesToUpdate) {
            $targetFile = Join-Path $dst $file
            if (Test-Path $targetFile) {
                (Get-Content $targetFile) -replace [regex]::Escape($FromVersion), $ToVersion |
                    Set-Content $targetFile
                # Also update 'Version: 0.1.0' style lines
                (Get-Content $targetFile) -replace "Version: ([0-9]+\.[0-9]+\.[0-9]+)", "Version: $($ToVersion.TrimStart('v'))" |
                    Set-Content $targetFile
            }
        }
    } else {
        Write-Host "Source version $src does not exist for $mod"
    }
} 