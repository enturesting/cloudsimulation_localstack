# Start all LocalStack environments
Write-Host "🚀 Starting all LocalStack environments..." -ForegroundColor Cyan

# Get API key from develop.auto.tfvars
$content = Get-Content "environments\develop.auto.tfvars" -Raw
if ($content -match 'localstack_api_key\s*=\s*"([^"]+)"') {
    $env:LOCALSTACK_API_KEY = $matches[1]
    Write-Host "✓ Found API key" -ForegroundColor Green
} else {
    Write-Host "❌ Could not find API key" -ForegroundColor Red
    exit 1
}

# Remove any existing containers
Write-Host "🧹 Cleaning up existing containers..." -ForegroundColor Yellow
docker rm -f localstack-develop localstack-nonprod localstack-staging localstack-prod 2>$null

# Start all environments
Write-Host "🚀 Starting develop..." -ForegroundColor Yellow
docker run -d --name localstack-develop -p 4566:4566 -e LOCALSTACK_API_KEY=$env:LOCALSTACK_API_KEY -e DEBUG=1 -e AWS_ACCESS_KEY_ID=develop-key -e AWS_SECRET_ACCESS_KEY=develop-secret localstack/localstack-pro:latest

Write-Host "🚀 Starting nonprod..." -ForegroundColor Yellow
docker run -d --name localstack-nonprod -p 4567:4566 -e LOCALSTACK_API_KEY=$env:LOCALSTACK_API_KEY -e DEBUG=1 -e AWS_ACCESS_KEY_ID=nonprod-key -e AWS_SECRET_ACCESS_KEY=nonprod-secret localstack/localstack-pro:latest

Write-Host "🚀 Starting staging..." -ForegroundColor Yellow
docker run -d --name localstack-staging -p 4568:4566 -e LOCALSTACK_API_KEY=$env:LOCALSTACK_API_KEY -e DEBUG=1 -e AWS_ACCESS_KEY_ID=staging-key -e AWS_SECRET_ACCESS_KEY=staging-secret localstack/localstack-pro:latest

Write-Host "🚀 Starting prod..." -ForegroundColor Yellow
docker run -d --name localstack-prod -p 4569:4566 -e LOCALSTACK_API_KEY=$env:LOCALSTACK_API_KEY -e DEBUG=1 -e AWS_ACCESS_KEY_ID=prod-key -e AWS_SECRET_ACCESS_KEY=prod-secret localstack/localstack-pro:latest

Write-Host ""
Write-Host "⏳ Waiting 20 seconds for initialization..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Write-Host ""
Write-Host "📋 Container Status:" -ForegroundColor Cyan
docker ps --filter "name=localstack" --format "table {{.Names}}\t{{.Status}}"

Write-Host ""
Write-Host "📋 Endpoints:" -ForegroundColor Cyan
Write-Host "  develop:  http://localhost:4566" -ForegroundColor White
Write-Host "  nonprod:  http://localhost:4567" -ForegroundColor White
Write-Host "  staging:  http://localhost:4568" -ForegroundColor White
Write-Host "  prod:     http://localhost:4569" -ForegroundColor White

Write-Host ""
Write-Host "✅ All environments started!" -ForegroundColor Green
