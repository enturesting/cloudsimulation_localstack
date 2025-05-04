# validate-metadata.ps1

$modulesPath = "..\modules"

Write-Host "🔍 Validating metadata.json for all modules..." -ForegroundColor Cyan

$errors = @()

Get-ChildItem -Path $modulesPath -Recurse -Filter "metadata.json" | ForEach-Object {
    $path = $_.FullName
    try {
        $json = Get-Content $path -Raw | ConvertFrom-Json
        if (-not $json.name -or -not $json.description -or -not $json.terraform_version) {
            $errors += "❌ Missing required field in: $path"
        }
    } catch {
        $errors += "❌ Invalid JSON format in: $path"
    }
}

if ($errors.Count -eq 0) {
    Write-Host "`n✅ All metadata.json files are valid." -ForegroundColor Green
} else {
    Write-Host "`nErrors found:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    exit 1
}
