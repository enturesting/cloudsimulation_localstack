# Check status of all LocalStack environments
Write-Host "📋 LocalStack Environment Status" -ForegroundColor Cyan
Write-Host ""

Write-Host "Container Status:" -ForegroundColor Yellow
docker ps --filter "name=localstack" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host ""
Write-Host "📋 Endpoints:" -ForegroundColor Cyan
Write-Host "  develop:  http://localhost:4566" -ForegroundColor White
Write-Host "  nonprod:  http://localhost:4567" -ForegroundColor White
Write-Host "  staging:  http://localhost:4568" -ForegroundColor White
Write-Host "  prod:     http://localhost:4569" -ForegroundColor White

Write-Host ""
Write-Host "🌐 LocalStack Cloud Dashboard:" -ForegroundColor Cyan
Write-Host "  https://app.localstack.cloud/instances" -ForegroundColor White
