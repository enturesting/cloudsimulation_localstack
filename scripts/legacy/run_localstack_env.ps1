param (
    [string]$env = "develop"
)

# Port mapping per environment
$ports = @{
    "develop" = @{ api = 4566; ui = 31566 }
    "nonprod" = @{ api = 4567; ui = 32566 }
}

if (-not $ports.ContainsKey($env)) {
    Write-Error "Unknown environment: $env. Allowed: develop, nonprod"
    exit 1
}

$apiPort = $ports[$env].api
$uiPort = $ports[$env].ui
$containerName = "localstack-$env"
$volumeName = "localstack-vol-$env"

# Check for existing container
$existingContainer = docker ps -a --filter "name=$containerName" --format "{{.Names}}"
if ($existingContainer) {
    Write-Host "A container named $containerName already exists." -ForegroundColor Yellow
    $response = Read-Host "Do you want to stop and remove it? (y/n)"
    if ($response -eq 'y') {
        Write-Host "Stopping and removing container..." -ForegroundColor Yellow
        docker stop $containerName | Out-Null
        docker rm $containerName | Out-Null
    } else {
        Write-Host "Aborting startup. Please remove or rename the existing container." -ForegroundColor Red
        exit 1
    }
}

# Check for existing volume
$existingVolume = docker volume ls --format "{{.Name}}" | Where-Object { $_ -eq $volumeName }
if ($existingVolume) {
    Write-Host "A volume named $volumeName already exists." -ForegroundColor Yellow
    $response = Read-Host "Do you want to remove it? (y/n)"
    if ($response -eq 'y') {
        Write-Host "Removing volume..." -ForegroundColor Yellow
        docker volume rm $volumeName -f | Out-Null
    } else {
        Write-Host "Aborting startup. Please remove or rename the existing volume." -ForegroundColor Red
        exit 1
    }
}

# Load LOCALSTACK_AUTH_TOKEN
$envFile = "environments/$env.auto.tfvars"
if (Test-Path $envFile) {
    $tfvarsContent = Get-Content $envFile -Raw
    $match = $tfvarsContent | Select-String -Pattern 'localstack_api_key\s*=\s*"(.+?)"'
    if ($match) {
        $env:LOCALSTACK_AUTH_TOKEN = $match.Matches[0].Groups[1].Value
        Write-Host "Loaded LOCALSTACK_AUTH_TOKEN from $envFile" -ForegroundColor Cyan
    } else {
        Write-Error "'localstack_api_key' not found in $envFile"
        exit 1
    }
} else {
    Write-Error "$envFile not found."
    exit 1
}

# Start container
docker run -d --name $containerName `
    -p "${apiPort}:4566" `
    -p "${uiPort}:31566" `
    -e LOCALSTACK_AUTH_TOKEN=$env:LOCALSTACK_AUTH_TOKEN `
    -e LOCALSTACK_HOST=localhost `
    -e LS_PLATFORM_MULTI_ACCOUNT=true `
    -v "${volumeName}:/var/lib/localstack" `
    -v "//var/run/docker.sock:/var/run/docker.sock" `
    localstack/localstack-pro

Start-Sleep -Seconds 10
Write-Host "`nLocalStack ($env) started at:"
Write-Host "  API: http://localhost:$apiPort"
Write-Host "  UI : http://localhost:$uiPort"
