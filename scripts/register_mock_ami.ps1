param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "develop", "nonprod")]
    [string]$Env
)

$autoTfvarsPath = Join-Path -Path $PSScriptRoot -ChildPath "..\environments\$Env.auto.tfvars"
$endpoint       = "http://localhost:4566"

Write-Host "Locating known-good AMI (amazonlinux-2023) for environment: $Env" -ForegroundColor Cyan

# Use AWS CLI to find the known-good image ID
try {
    $amiId = aws ec2 describe-images `
        --endpoint-url $endpoint `
        --query "Images[?Name=='amazonlinux-2023'].ImageId" `
        --output text
} catch {
    Write-Host "`nError querying LocalStack for AMI." -ForegroundColor Red
    exit 1
}

if (-not $amiId) {
    Write-Host "`nFailed to locate known-good AMI: amazonlinux-2023" -ForegroundColor Red
    exit 1
}

Write-Host "`nFound AMI: $amiId" -ForegroundColor Green

# Update ami_id in the environment's tfvars
if (Test-Path $autoTfvarsPath) {
    (Get-Content $autoTfvarsPath) -replace 'ami_id\s*=\s*".*"', "ami_id = `"$amiId`"" |
        Set-Content $autoTfvarsPath -Encoding utf8

    Write-Host "`nUpdated $autoTfvarsPath with:" -ForegroundColor Yellow
    Write-Host "ami_id = $amiId" -ForegroundColor White
} else {
    Write-Host "`nFile not found: $autoTfvarsPath" -ForegroundColor Red
}
