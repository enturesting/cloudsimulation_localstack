# Stop all LocalStack environments
Write-Host "🛑 Stopping all LocalStack environments..." -ForegroundColor Cyan

Write-Host "Stopping containers..." -ForegroundColor Yellow
docker rm -f localstack-develop localstack-nonprod localstack-staging localstack-prod 2>$null

Write-Host ""
Write-Host "📋 Remaining containers:" -ForegroundColor Cyan
docker ps --filter "name=localstack" --format "table {{.Names}}	{{.Status}}"

Write-Host ""
Write-Host "✅ All environments stopped!" -ForegroundColor Green
