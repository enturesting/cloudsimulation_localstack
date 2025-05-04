# ci_docs_validate.ps1

Write-Host "CI: Validating that each module has docs/content.md..."

$modules = Get-ChildItem -Path ../modules -Directory
$missingDocs = @()

foreach ($module in $modules) {
    $docsPath = "$($module.FullName)\\docs\\content.md"
    if (-not (Test-Path $docsPath)) {
        $missingDocs += $module.Name
    }
}

if ($missingDocs.Count -eq 0) {
    Write-Host "All modules have long-form docs." -ForegroundColor Green
} else {
    Write-Host "Missing content.md in:" -ForegroundColor Red
    $missingDocs | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    exit 1
}
