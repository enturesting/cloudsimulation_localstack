# Docker cleanup for LocalStack environments
Write-Host "🧹 LocalStack Docker Cleanup" -ForegroundColor Cyan
Write-Host ""

Write-Host "Current LocalStack containers:" -ForegroundColor Yellow
docker ps -a --filter "name=localstack" --format "table {{.Names}}\t{{.Status}}"

Write-Host ""
$choice = Read-Host "Remove all LocalStack containers? (y/N)"
if ($choice -eq 'y' -or $choice -eq 'Y') {
    Write-Host "Removing LocalStack containers..." -ForegroundColor Yellow
    docker rm -f localstack-develop localstack-nonprod localstack-staging localstack-prod 2>$null
    Write-Host "✓ Containers removed" -ForegroundColor Green
}

Write-Host ""
$choice = Read-Host "Remove unused Docker networks? (y/N)"
if ($choice -eq 'y' -or $choice -eq 'Y') {
    Write-Host "Removing unused networks..." -ForegroundColor Yellow
    docker network prune -f
    Write-Host "✓ Networks cleaned" -ForegroundColor Green
}

Write-Host ""
$choice = Read-Host "Remove unused Docker volumes? (y/N)"
if ($choice -eq 'y' -or $choice -eq 'Y') {
    Write-Host "Removing unused volumes..." -ForegroundColor Yellow
    docker volume prune -f
    Write-Host "✓ Volumes cleaned" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Cleanup complete!" -ForegroundColor Green
