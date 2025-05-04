param (
    [string]$env = "develop"
)

$containerName = "localstack-$env"
$volumeName = "localstack-vol-$env"
$uiPort = if ($env -eq "develop") { 31566 } elseif ($env -eq "nonprod") { 31567 } else { 31568 }

Write-Host "Resetting LocalStack for environment: $env" -ForegroundColor Cyan
Write-Host "Container: $containerName" -ForegroundColor Gray
Write-Host "Volume: $volumeName" -ForegroundColor Gray
Write-Host "UI Port: $uiPort" -ForegroundColor Gray

# Stop and remove container
Write-Host "Stopping and removing container..." -ForegroundColor Yellow
docker stop $containerName | Out-Null
docker rm $containerName | Out-Null

# Remove volume
Write-Host "Removing volume (if it exists)..." -ForegroundColor Yellow
docker volume rm $volumeName -f 2>$null

# Check for port conflict
$portCheck = docker ps --filter "publish=$uiPort" --format "{{.Names}}"
if ($portCheck) {
    Write-Host "`n Port $uiPort is already in use by container: $portCheck" -ForegroundColor Red
    Write-Host "Please stop or remove that container manually before resetting this environment." -ForegroundColor Yellow
    Write-Host "Example: docker stop $portCheck; docker rm $portCheck" -ForegroundColor Gray
    exit 1
}

# Load LOCALSTACK_AUTH_TOKEN
$envFile = "environments/$env.auto.tfvars"
if (-not (Test-Path $envFile)) {
    Write-Host "`n $envFile not found." -ForegroundColor Red
    Write-Host "You must provide a valid .auto.tfvars file with localstack_api_key for this environment." -ForegroundColor Yellow
    exit 1
}

$tfvarsContent = Get-Content $envFile -Raw
$match = $tfvarsContent | Select-String -Pattern 'localstack_api_key\s*=\s*"(.+?)"'
if (-not $match) {
    Write-Host "`n Missing 'localstack_api_key' in $envFile." -ForegroundColor Red
    exit 1
}
$env:LOCALSTACK_AUTH_TOKEN = $match.Matches[0].Groups[1].Value
Write-Host "Loaded LOCALSTACK_AUTH_TOKEN from $envFile" -ForegroundColor Cyan

$apiPort          = if ($env -eq "develop") { 4566 } elseif ($env -eq "nonprod") { 4567 } else { 4568 }
$uiPort           = if ($env -eq "develop") { 31566 } elseif ($env -eq "nonprod") { 31567 } else { 31568 }
$servicePortRange = if ($env -eq "develop") { "4510-4559" } elseif ($env -eq "nonprod") { "4610-4659" } else { "4710-4759" }
$httpsPort        = if ($env -eq "develop") { 8443 } elseif ($env -eq "nonprod") { 8444 } else { 8445 }

docker run -d --name $containerName `
  -p "${apiPort}:4566" `
  -p "${servicePortRange}:${servicePortRange}" `
  -p "${uiPort}:8080" `
  -p "${httpsPort}:443" `
  -e LOCALSTACK_AUTH_TOKEN=$env:LOCALSTACK_AUTH_TOKEN `
  -e LOCALSTACK_HOST=localhost `
  -e LS_PLATFORM_MULTI_ACCOUNT=true `
  -v "/var/run/docker.sock:/var/run/docker.sock" `
  -v "${volumeName}:/var/lib/localstack" `
  localstack/localstack-pro


Start-Sleep -Seconds 10
Write-Host "`n LocalStack ($env) has been reset and restarted." -ForegroundColor Green
Write-Host "UI available at: http://localhost:$uiPort" -ForegroundColor White

# Optional health check
try {
    $health = Invoke-RestMethod http://localhost:4566/_localstack/health
    Write-Host "`nLocalStack Health Status:" -ForegroundColor Gray
    $health | ConvertTo-Json -Depth 5 | Write-Host
} catch {
    Write-Host "`n Health check failed. LocalStack may not be fully ready yet." -ForegroundColor DarkYellow
}
