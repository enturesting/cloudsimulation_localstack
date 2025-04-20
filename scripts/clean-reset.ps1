param (
    [string]$env,
    [switch]$AutoApprove
)

Write-Host "`n==== CLEAN RESET SCRIPT FOR LOCALSTACK ($env) ====" -ForegroundColor Cyan

# Load from auto.tfvars.json instead of hardcoded credentials
$secretsFile = "environments\$env.auto.tfvars.json"
if (-not (Test-Path $secretsFile)) {
    Write-Host "❌ Secrets file not found: $secretsFile" -ForegroundColor Red
    Write-Host "Please create it from the .example file or update manually."
    exit 1
}

$secrets = Get-Content $secretsFile | ConvertFrom-Json

# Validate expected keys
if (-not $secrets.account_id -or -not $secrets.access_key -or -not $secrets.secret_key) {
    Write-Host "Missing one or more required keys in `${secretsFile}`:`nExpected:" -ForegroundColor Red
    Write-Host "  - account_id"
    Write-Host "  - access_key"
    Write-Host "  - secret_key"
    exit 1
}

# Export as env vars
$env:AWS_ACCESS_KEY_ID  = $secrets.access_key
$env:AWS_SECRET_ACCESS_KEY = $secrets.secret_key
$env:AWS_ACCOUNT_ID     = $secrets.account_id

# Prompt user before nuking
if (-not $AutoApprove) {
    $confirm = Read-Host "This will nuke S3, DynamoDB, EC2, IAM, KMS, and VPC resources in LocalStack for '$env'. Continue? (y/n)"
    if ($confirm -ne 'y') {
        Write-Host "Aborting reset." -ForegroundColor Yellow
        exit 0
    }
}

function Clear-S3Buckets {
    Write-Host "`nDeleting all S3 buckets..." -ForegroundColor Cyan
    $buckets = aws --endpoint-url=http://localhost:4566 s3api list-buckets | ConvertFrom-Json
    foreach ($bucket in $buckets.Buckets) {
        $name = $bucket.Name
        Write-Host " - Deleting bucket: $name"
        aws --endpoint-url=http://localhost:4566 s3 rb s3://$name --force
    }
}

function Clear-DynamoDBTables {
    Write-Host "`nDeleting all DynamoDB tables..." -ForegroundColor Cyan
    $tables = aws --endpoint-url=http://localhost:4566 dynamodb list-tables | ConvertFrom-Json
    foreach ($table in $tables.TableNames) {
        Write-Host " - Deleting table: $table"
        aws --endpoint-url=http://localhost:4566 dynamodb delete-table --table-name $table
    }
}

function Schedule-KMSDeletions {
    Write-Host "`nScheduling deletion of KMS keys..." -ForegroundColor Cyan
    $keys = aws --endpoint-url=http://localhost:4566 kms list-keys | ConvertFrom-Json
    foreach ($key in $keys.Keys) {
        $keyId = $key.KeyId
        Write-Host " - Scheduling deletion for key: $keyId"
        $null = aws --endpoint-url=http://localhost:4566 kms schedule-key-deletion --key-id $keyId --pending-window-in-days 7 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "   - Skipping (likely already pending deletion): $keyId"
        }
    }
}

function Clear-EC2Instances {
    Write-Host "`nTerminating EC2 instances..." -ForegroundColor Cyan
    $instances = aws --endpoint-url=http://localhost:4566 ec2 describe-instances | ConvertFrom-Json
    $instanceIds = @()
    foreach ($reservation in $instances.Reservations) {
        foreach ($instance in $reservation.Instances) {
            $instanceIds += $instance.InstanceId
        }
    }
    if ($instanceIds.Count -gt 0) {
        Write-Host " - Terminating instances: $($instanceIds -join ', ')"
        aws --endpoint-url=http://localhost:4566 ec2 terminate-instances --instance-ids $instanceIds
    } else {
        Write-Host " - No instances found."
    }
}

function Clear-IAMRoles {
    Write-Host "`nDeleting IAM roles..." -ForegroundColor Cyan
    $roles = aws --endpoint-url=http://localhost:4566 iam list-roles | ConvertFrom-Json
    foreach ($role in $roles.Roles) {
        $roleName = $role.RoleName
        Write-Host " - Processing role: $roleName"

        $inlinePolicies = aws --endpoint-url=http://localhost:4566 iam list-role-policies --role-name $roleName | ConvertFrom-Json
        foreach ($policyName in $inlinePolicies.PolicyNames) {
            Write-Host "   - Deleting inline policy: $policyName"
            aws --endpoint-url=http://localhost:4566 iam delete-role-policy --role-name $roleName --policy-name $policyName
        }

        $attached = aws --endpoint-url=http://localhost:4566 iam list-attached-role-policies --role-name $roleName | ConvertFrom-Json
        foreach ($attachedPolicy in $attached.AttachedPolicies) {
            $arn = $attachedPolicy.PolicyArn
            Write-Host "   - Detaching managed policy: $arn"
            aws --endpoint-url=http://localhost:4566 iam detach-role-policy --role-name $roleName --policy-arn $arn
        }

        Write-Host "   - Deleting role: $roleName"
        try {
            aws --endpoint-url=http://localhost:4566 iam delete-role --role-name $roleName
        } catch {
            Write-Host "   - Failed to delete role: $($_.Exception.Message)"
        }
    }
}

function Clear-VPCStack {
    Write-Host "`nCleaning up VPC stack (Subnets, IGWs, RTs, SGs, VPCs)..." -ForegroundColor Cyan
    $endpoint = "http://localhost:4566"

    $sgs = aws --endpoint-url=$endpoint ec2 describe-security-groups | ConvertFrom-Json
    foreach ($sg in $sgs.SecurityGroups) {
        if ($sg.GroupName -ne "default") {
            Write-Host " - Deleting security group: $($sg.GroupId)"
            aws --endpoint-url=$endpoint ec2 delete-security-group --group-id $sg.GroupId 2>$null
        }
    }

    $subnets = aws --endpoint-url=$endpoint ec2 describe-subnets | ConvertFrom-Json
    foreach ($subnet in $subnets.Subnets) {
        Write-Host " - Deleting subnet: $($subnet.SubnetId)"
        aws --endpoint-url=$endpoint ec2 delete-subnet --subnet-id $subnet.SubnetId 2>$null
    }

    $igws = aws --endpoint-url=$endpoint ec2 describe-internet-gateways | ConvertFrom-Json
    foreach ($igw in $igws.InternetGateways) {
        foreach ($attachment in $igw.Attachments) {
            Write-Host " - Detaching IGW: $($igw.InternetGatewayId) from VPC: $($attachment.VpcId)"
            aws --endpoint-url=$endpoint ec2 detach-internet-gateway --internet-gateway-id $igw.InternetGatewayId --vpc-id $attachment.VpcId 2>$null
        }
        Write-Host " - Deleting internet gateway: $($igw.InternetGatewayId)"
        aws --endpoint-url=$endpoint ec2 delete-internet-gateway --internet-gateway-id $igw.InternetGatewayId 2>$null
    }

    $routeTables = aws --endpoint-url=$endpoint ec2 describe-route-tables | ConvertFrom-Json
    foreach ($rt in $routeTables.RouteTables) {
        $mainAssociation = $rt.Associations | Where-Object { $_.Main -eq $true }
        if (-not $mainAssociation) {
            Write-Host " - Deleting route table: $($rt.RouteTableId)"
            aws --endpoint-url=$endpoint ec2 delete-route-table --route-table-id $rt.RouteTableId 2>$null
        }
    }

    try {
        $natGateways = aws --endpoint-url=$endpoint ec2 describe-nat-gateways | ConvertFrom-Json
        foreach ($nat in $natGateways.NatGateways) {
            Write-Host " - Deleting NAT gateway: $($nat.NatGatewayId)"
            aws --endpoint-url=$endpoint ec2 delete-nat-gateway --nat-gateway-id $nat.NatGatewayId 2>$null
        }
    } catch {
        Write-Host " - Skipping NAT gateway cleanup (not supported or none exist)"
    }

    $vpcs = aws --endpoint-url=$endpoint ec2 describe-vpcs | ConvertFrom-Json
    foreach ($vpc in $vpcs.Vpcs) {
        Write-Host " - Deleting VPC: $($vpc.VpcId)"
        aws --endpoint-url=$endpoint ec2 delete-vpc --vpc-id $vpc.VpcId 2>$null
    }
}

Clear-S3Buckets
Clear-DynamoDBTables
Schedule-KMSDeletions
Clear-EC2Instances
Clear-IAMRoles
Clear-VPCStack

Write-Host "`nAll resources scheduled for deletion or force-deleted for '$env'. LocalStack is clean." -ForegroundColor Green
