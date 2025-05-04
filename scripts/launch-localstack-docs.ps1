# launch_localstack_docs.ps1

Write-Host "`n🚀 Starting LocalStack and Docsify..." -ForegroundColor Cyan

# Start LocalStack container
docker start localstack_main | Out-Null
Start-Sleep -Seconds 5

# Serve Docsify site
Start-Process powershell -ArgumentList "docsify serve docs"
Start-Sleep -Seconds 2

# Launch browser to Docsify site
Start-Process "http://localhost:3000"
