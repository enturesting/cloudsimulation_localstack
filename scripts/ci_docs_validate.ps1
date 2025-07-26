# ci_docs_validate.ps1

Write-Host "CI: Validating that each module version has README.md documentation..."

# Handle both local and CI execution contexts
$modulesPath = if (Test-Path "../modules") { "../modules" } else { "./modules" }
$modules = Get-ChildItem -Path $modulesPath -Directory
$missingDocs = @()

foreach ($module in $modules) {
    # Check each version subdirectory for README.md
    $versions = Get-ChildItem -Path $module.FullName -Directory | Where-Object { $_.Name -match "^v\d+\.\d+\.\d+$" }
    foreach ($version in $versions) {
        $readmePath = "$($version.FullName)\\README.md"
        if (-not (Test-Path $readmePath)) {
            $missingDocs += "$($module.Name)/$($version.Name)"
        }
    }
}

if ($missingDocs.Count -eq 0) {
    Write-Host "All module versions have README.md documentation." -ForegroundColor Green
} else {
    Write-Host "Missing README.md in:" -ForegroundColor Red
    $missingDocs | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    exit 1
}
