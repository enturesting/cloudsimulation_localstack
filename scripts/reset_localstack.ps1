# reset_localstack.ps1

Write-Host "Stopping and removing LocalStack container..." -ForegroundColor Yellow
docker stop localstack | Out-Null
docker rm localstack | Out-Null

# Write-Host "Restarting LocalStack with Docker (stateless)..." -ForegroundColor Cyan
Write-Host "Removing LocalStack volume (if any)..." -ForegroundColor Yellow
docker volume rm localstack_localstack -f 2>$null

if (-not $env:LOCALSTACK_AUTH_TOKEN) {
  Write-Error "LOCALSTACK_AUTH_TOKEN is not set. Please set it as an environment variable."
  exit 1
}

docker run -d --name localstack `
  -p 4566:4566 -p 4510-4559:4510-4559 -p 8080:8080 -p 443:443 `
  -p 53:53 -p 53:53/udp -p 31566:31566 `
  -e LOCALSTACK_AUTH_TOKEN=$env:LOCALSTACK_AUTH_TOKEN `
  -e LOCALSTACK_HOST=localhost `
  -e LS_PLATFORM_MULTI_ACCOUNT=true `
  -v "//var/run/docker.sock:/var/run/docker.sock" `
  localstack/localstack-pro
Start-Sleep -Seconds 10
Write-Host "`nLocalStack has been reset and restarted (stateless)." -ForegroundColor Green

# Optional health check
Invoke-RestMethod http://localhost:4566/_localstack/health | ConvertTo-Json | Write-Host