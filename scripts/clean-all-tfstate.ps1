Write-Host "`n==== GLOBAL TERRAFORM STATE CLEANUP ====" -ForegroundColor Cyan

# Define folders where Terraform state might live
$envPaths = @(
    "$PSScriptRoot\..\environments",
    "$PSScriptRoot\..",
    "$PSScriptRoot\..\modules",
    "$PSScriptRoot\..\scripts",
    "$PSScriptRoot\..\test"
)

# Files and folders to remove
$tfStateFiles = @("terraform.tfstate", "terraform.tfstate.backup", ".terraform.lock.hcl")
$tfDirs = @(".terraform", "terraform.tfstate.d")

foreach ($path in $envPaths) {
    $resolvedPath = Resolve-Path $path -ErrorAction SilentlyContinue
    if ($resolvedPath) {
        Write-Host "`n🧹 Checking: $resolvedPath" -ForegroundColor Yellow

        foreach ($file in $tfStateFiles) {
            $filePath = Join-Path $resolvedPath $file
            if (Test-Path $filePath) {
                try {
                    Remove-Item -Force $filePath -ErrorAction Stop
                    Write-Host " Removed file: $file" -ForegroundColor Green
                }
                catch {
                    Write-Host "⚠ Could not remove file: $filePath" -ForegroundColor DarkGray
                }
            }
        }

        foreach ($dir in $tfDirs) {
            $dirPath = Join-Path $resolvedPath $dir
            if (Test-Path $dirPath) {
                try {
                    Remove-Item -Recurse -Force $dirPath -ErrorAction Stop
                    Write-Host " Removed directory: $dir" -ForegroundColor Green
                }
                catch {
                    Write-Host " Could not remove directory: $dirPath" -ForegroundColor DarkGray
                }
            }
        }
    }
}

Write-Host "`n All Terraform state cleanup attempted. Locked files (if any) were skipped safely." -ForegroundColor Cyan
