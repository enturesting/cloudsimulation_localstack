param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "nonprod")]
    [string]$Env
)

$amiName    = "mock-$Env-ami"
$autoTfvarsPath = Join-Path -Path $PSScriptRoot -ChildPath "..\environments\$Env.auto.tfvars.json"
$endpoint   = "http://localhost:4566"
$tmpFile    = "$env:TEMP\register-ami-$Env.json"

Write-Host "📦 Registering mock AMI for environment: $Env"

# Block device mappings
$blockDeviceMappings = @(
    @{
        DeviceName = "/dev/xvda"
        Ebs = @{
            VolumeSize = 8
        }
    }
)

# Payload to register AMI
$payload = @{
    Name                = $amiName
    Description         = "LocalStack mock AMI for $Env"
    Architecture        = "x86_64"
    RootDeviceName      = "/dev/xvda"
    VirtualizationType  = "hvm"
    BlockDeviceMappings = $blockDeviceMappings
}

# Write payload to JSON file
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($tmpFile, ($payload | ConvertTo-Json -Depth 5 -Compress), $utf8NoBom)

Write-Host "`n📄 Generated AMI JSON:"
Get-Content $tmpFile | Write-Host

# Register the AMI via AWS CLI (LocalStack)
try {
    $amiResponse = aws --endpoint-url=$endpoint ec2 register-image --region us-east-1 --cli-input-json file://$tmpFile | ConvertFrom-Json
} catch {
    Write-Host "❌ AWS CLI failed to register AMI." -ForegroundColor Red
    Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
    exit 1
}

Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue

$amiId = $amiResponse.ImageId
if (-not $amiId) {
    Write-Host "❌ Failed to register mock AMI (no ID returned)." -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Registered mock AMI: $amiId"

# Load or create auto.tfvars.json
if (Test-Path $autoTfvarsPath) {
    $json = Get-Content $autoTfvarsPath | ConvertFrom-Json
} else {
    $json = @{}
}

# Update or insert ami_id
$json.ami_id = $amiId

# Save updated JSON
$json | ConvertTo-Json -Depth 5 | Out-File -Encoding UTF8 -FilePath $autoTfvarsPath

Write-Host "`n✅ Updated $autoTfvarsPath with:"
Write-Host "ami_id = $amiId"
