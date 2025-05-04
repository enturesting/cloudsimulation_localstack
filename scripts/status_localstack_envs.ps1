# status_localstack_envs.ps1
$knownEnvs = @{
    "develop" = @{ api = 4566; ui = 31566 }
    "nonprod" = @{ api = 4567; ui = 32566 }
}

Write-Host "`nLocalStack Container Status" -ForegroundColor Cyan
Write-Host "---------------------------"

foreach ($env in $knownEnvs.Keys) {
    $container = "localstack-$env"
    $status = docker ps -a --filter "name=$container" --format "{{.Status}}"

    if ($status) {
        Write-Host "${env}:`t$container is $status"
        Write-Host "  API Port:`thttp://localhost:$($knownEnvs[$env].api)"
        Write-Host "  UI  Port:`thttp://localhost:$($knownEnvs[$env].ui)"
    } else {
        Write-Host "${env}:`t$container not found or not running" -ForegroundColor DarkGray
    }

    Write-Host ""
}
