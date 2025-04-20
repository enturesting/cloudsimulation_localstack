param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("dev", "nonprod")]
    [string]$Env
)

$amiName    = "mock-$Env-ami"
$tfvarsPath = Join-Path -Path $PSScriptRoot -ChildPath "..\environments\$Env.tfvars"
$endpoint   = "http://localhost:4566"
$tmpFile    = "$env:TEMP\register-ami-$Env.json"

Write-Host "Registering mock AMI for environment: $Env"

# Build block device mappings in proper structure
$blockDeviceMappings = @(
    @{
        DeviceName = "/dev/xvda"
        Ebs = @{
            VolumeSize = 8
        }
    }
)

# Full request body
$payload = @{
    Name                = $amiName
    Description         = "LocalStack mock AMI for $Env"
    Architecture        = "x86_64"
    RootDeviceName      = "/dev/xvda"
    VirtualizationType  = "hvm"
    BlockDeviceMappings = $blockDeviceMappings
}

# Convert to properly formatted JSON for AWS CLI
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($tmpFile, ($payload | ConvertTo-Json -Depth 5 -Compress), $utf8NoBom)

# Validate file contents
Write-Host "`nGenerated JSON:"
Get-Content $tmpFile | Write-Host

# Register AMI with LocalStack
try {
    $amiResponse = aws --endpoint-url=$endpoint ec2 register-image --region us-east-1 --cli-input-json file://$tmpFile | ConvertFrom-Json
} catch {
    Write-Host "AWS CLI failed to register AMI."
    Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
    exit 1
}

Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue

$amiId = $amiResponse.ImageId
if (-not $amiId) {
    Write-Host "Failed to register mock AMI (no ID returned)."
    exit 1
}

Write-Host "Registered mock AMI: $amiId"

# Update tfvars file with new AMI
Write-Host "`nUpdating $tfvarsPath with new AMI ID..."
$content = Get-Content $tfvarsPath
$updated = $false

$modifiedContent = $content | ForEach-Object {
    if ($_ -match '^\s*ami\s*=') {
        $updated = $true
        "ami = `"$amiId`""
    } else {
        $_
    }
}

if (-not $updated) {
    $modifiedContent += "ami = `"$amiId`""
}

$modifiedContent | Set-Content $tfvarsPath
Write-Host "Updated $tfvarsPath with: ami = $amiId"
