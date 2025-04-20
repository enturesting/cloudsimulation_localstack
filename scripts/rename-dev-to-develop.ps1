# rename-dev-to-develop.ps1

$root = Get-Location
$oldName = "develop.tfvars"
$newName = "develop.tfvars"

# Rename the tfvars file
$oldPath = Join-Path $root $oldName
$newPath = Join-Path $root $newName

if (Test-Path $oldPath) {
    Rename-Item -Path $oldPath -NewName $newName
    Write-Host "Renamed '$oldName' → '$newName'" -ForegroundColor Green
} else {
    Write-Host "File '$oldName' not found. Skipping rename." -ForegroundColor Yellow
}

# Update all script/code files with "develop.tfvars" reference
$extensions = @("*.ps1", "*.tf", "*.yml", "*.md")
foreach ($ext in $extensions) {
    Get-ChildItem -Path $root -Recurse -Filter $ext | ForEach-Object {
        (Get-Content $_.FullName) -replace "\bdev\.tfvars\b", "develop.tfvars" |
            Set-Content $_.FullName
    }
}
Write-Host "Updated references to '$oldName' in project files." -ForegroundColor Cyan
