param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "nonprod", "all")]
    [string]$Env
)

$endpoint = "http://localhost:4566"

function Show-Resources($profile) {
    Write-Host "`nResources for profile: $profile" -ForegroundColor Cyan

    Write-Host "`nS3 Buckets:" -ForegroundColor Yellow
    aws --endpoint-url=$endpoint --profile $profile s3 ls

    Write-Host "`nDynamoDB Tables:" -ForegroundColor Yellow
    aws --endpoint-url=$endpoint --profile $profile dynamodb list-tables

    Write-Host "`nIAM Roles:" -ForegroundColor Yellow
    aws --endpoint-url=$endpoint --profile $profile iam list-roles

    Write-Host "`nEC2 Instances:" -ForegroundColor Yellow
    aws --endpoint-url=$endpoint --profile $profile ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' --output table
}

if ($Env -eq "all") {
    Show-Resources -profile "dev"
    Show-Resources -profile "nonprod"
} else {
    Show-Resources -profile $Env
}
