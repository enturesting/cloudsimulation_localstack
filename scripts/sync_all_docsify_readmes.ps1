<#
.SYNOPSIS
  Synchronizes all module and top-level README.md files into the /docs/ structure for Docsify and GitHub Pages.

.DESCRIPTION
  This script ensures that all relevant README.md documentation files from your Terraform simulation project
  are correctly copied into the /docs/ folder so they can be rendered by Docsify and included in GitHub Pages builds.

  It handles:
    - Copying /modules/*/README.md into /docs/modules/*/
    - Copying /scripts/README.md, /test/README.md, and /environments/README.md into matching /docs/ subfolders
    - Automatically creating missing /docs/ subfolders
    - Removing stale or outdated copies before updating
    - Preventing failures due to prior symlinks or directory conflicts

  GitHub Pages does not support symbolic links or out-of-folder references when archiving files,
  so this script ensures all files are flattened into /docs/ as real content. Run this script
  before committing and pushing to ensure updated documentation pages.

  From repo root directory, run:
    powershell -ExecutionPolicy Bypass -File scripts\sync_all_docsify_readmes.ps1
#>


# scripts/sync_all_docsify_readmes.ps1
# Get repo root
$repoRoot = Resolve-Path "$PSScriptRoot\.."
$modulesPath = Join-Path $repoRoot "modules"
$docsPath = Join-Path $repoRoot "docs"

Write-Host ""
Write-Host "Syncing versioned module README.md files..."

# Sync modules/*/v*/README.md → docs/modules/*/v*/README.md
$modules = Get-ChildItem -Directory -Path $modulesPath
foreach ($mod in $modules) {
    $modName = $mod.Name
    $versionDirs = Get-ChildItem -Directory -Path $mod.FullName | Where-Object { $_.Name -match '^v[0-9]+\.[0-9]+\.[0-9]+' }
    foreach ($ver in $versionDirs) {
        $verName = $ver.Name
        $sourceReadme = Join-Path $ver.FullName "README.md"
        $targetDir = Join-Path $docsPath "modules\$modName\$verName"
        $targetReadme = Join-Path $targetDir "README.md"

        # Ensure target dir exists
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        # Remove any old file first to avoid caching issues
        if (Test-Path $targetReadme) {
            Remove-Item -Path $targetReadme -Force
        }

        # Copy over the latest file
        if (Test-Path $sourceReadme) {
            Copy-Item -Path $sourceReadme -Destination $targetReadme -Force
            Write-Host "Copied module README.md: $modName/$verName"
        } else {
            Write-Host "Missing README.md in module: $modName/$verName"
        }
    }
}

Write-Host ""
Write-Host "Syncing top-level README.md files..."

# Top-level folders to process
$topLevelFolders = @("test", "scripts", "environments")
foreach ($folder in $topLevelFolders) {
    $sourceReadme = Join-Path $repoRoot "$folder\README.md"
    $targetDir = Join-Path $docsPath $folder
    $targetReadme = Join-Path $targetDir "README.md"

    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    if (Test-Path $targetReadme) {
        Remove-Item -Path $targetReadme -Force
    }

    if (Test-Path $sourceReadme) {
        Copy-Item -Path $sourceReadme -Destination $targetReadme -Force
        Write-Host "Copied top-level README.md: $folder"
    } else {
        Write-Host "Missing top-level README.md: $folder"
    }
}

Write-Host ""
Write-Host "All README.md files synced into docs structure."
