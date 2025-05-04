# purge_mock_amis.ps1
# Deletes all mock AMIs (name starts with "mock-") from LocalStack

Write-Host "`n==== PURGING MOCK AMIs FROM LOCALSTACK ====" -ForegroundColor Cyan

# Ensure AWS CLI is available
if (-not (Get-Command "aws" -ErrorAction SilentlyContinue)) {
    Write-Host "AWS CLI not found in PATH." -ForegroundColor Red
    exit 1
}

# Set LocalStack endpoint
$endpoint = "http://localhost:4566"

# Retrieve mock AMIs
try {
    $mockAmis = aws ec2 describe-images `
        --endpoint-url $endpoint `
        --query "Images[?starts_with(Name, 'mock-')].ImageId" `
        --output text
} catch {
    Write-Host "Failed to query AMIs from LocalStack." -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($mockAmis)) {
    Write-Host "No mock AMIs found to purge." -ForegroundColor Yellow
    exit 0
}

$mockAmisList = $mockAmis -split "\s+"

foreach ($amiId in $mockAmisList) {
    Write-Host "🧹 Deregistering AMI: $amiId"
    aws ec2 deregister-image --image-id $amiId --endpoint-url $endpoint
}

Write-Host "`nPurge complete. Deregistered $($mockAmisList.Count) mock AMI(s)." -ForegroundColor Green
