# bootstrap_dev_env.ps1

Write-Host "`n🧪 Bootstrapping Terraform Local Dev Environment..." -ForegroundColor Cyan
& ./scripts/reset_localstack.ps1
& ./scripts/apply_env.ps1 -Env develop
& ./scripts/launch_localstack_docs.ps1
