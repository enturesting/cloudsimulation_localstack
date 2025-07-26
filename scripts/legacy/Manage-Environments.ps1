param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("develop", "nonprod", "staging", "prod", "all")]
    [string]$Environment = "all",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("us-east-1", "us-east-2", "all")]
    [string]$Region = "all",
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("start", "stop", "deploy", "destroy", "test", "status", "clean")]
    [string]$Action
)

# Configuration
$Environments = @("develop", "nonprod", "staging", "prod")
$Regions = @("us-east-1", "us-east-2")
$PortMap = @{
    "develop" = 4566
    "nonprod" = 4567
    "staging" = 4568
    "prod" = 4569
}

# Color functions
function Write-Success { param([string]$Message) Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
function Write-Error { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Write-Warning { param([string]$Message) Write-Host "[WARNING] $Message" -ForegroundColor Yellow }
function Write-Info { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }

function Test-EnvironmentHealth {
    param([string]$Env)
    
    $Port = $PortMap[$Env]
    try {
        $Response = Invoke-RestMethod -Uri "http://localhost:$Port/_localstack/health" -TimeoutSec 5
        $Services = $Response.services
        $HealthyServices = ($Services.PSObject.Properties | Where-Object { $_.Value -eq "available" }).Count
        $TotalServices = $Services.PSObject.Properties.Count
        
        if ($HealthyServices -eq $TotalServices) {
            Write-Success "$Env environment: $HealthyServices/$TotalServices services healthy (port $Port)"
            return $true
        } else {
            Write-Warning "$Env environment: $HealthyServices/$TotalServices services healthy (port $Port)"
            return $false
        }
    } catch {
        Write-Error "$Env environment: Not responding (port $Port)"
        return $false
    }
}

function Start-Environment {
    param([string]$Env)
    
    Write-Info "Starting $Env environment..."
    try {
        if ($Env -eq "all") {
            $result = docker-compose -f docker-compose.enhanced.yml up -d
        } else {
            $result = docker-compose -f docker-compose.enhanced.yml up -d "localstack-$Env"
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Info "Waiting for environment(s) to be ready..."
            Start-Sleep -Seconds 15
            
            if ($Env -eq "all") {
                foreach ($e in $Environments) {
                    Test-EnvironmentHealth $e | Out-Null
                }
            } else {
                Test-EnvironmentHealth $Env | Out-Null
            }
        } else {
            Write-Error "Failed to start $Env environment"
        }
    } catch {
        Write-Error "Error starting $Env environment: $($_.Exception.Message)"
    }
}

function Stop-Environment {
    param([string]$Env)
    
    Write-Info "Stopping $Env environment..."
    try {
        if ($Env -eq "all") {
            docker-compose -f docker-compose.enhanced.yml down
            Write-Success "All environments stopped"
        } else {
            docker-compose -f docker-compose.enhanced.yml stop "localstack-$Env"
            Write-Success "$Env environment stopped"
        }
    } catch {
        Write-Error "Error stopping $Env environment: $($_.Exception.Message)"
    }
}

function Setup-EnvironmentConfig {
    param([string]$Env, [string]$Reg)
    
    $ConfigPath = "environments\$Env\$Reg"
    $TfVarsPath = "$ConfigPath\terraform.tfvars"
    $TemplatePath = "$ConfigPath\terraform.tfvars.template"
    $MainTfPath = "$ConfigPath\main.tf"
    
    # Create terraform.tfvars from template if it doesn't exist
    if (-not (Test-Path $TfVarsPath) -and (Test-Path $TemplatePath)) {
        Copy-Item $TemplatePath $TfVarsPath
        Write-Success "Created terraform.tfvars from template for $Env/$Reg"
    }
    
    # Copy main.tf if it doesn't exist
    if (-not (Test-Path $MainTfPath) -and (Test-Path "environments\main.tf")) {
        Copy-Item "environments\main.tf" $MainTfPath
        Write-Success "Created main.tf for $Env/$Reg"
    }
    
    return (Test-Path $TfVarsPath)
}

function Deploy-Environment {
    param([string]$Env, [string]$Reg)
    
    Write-Info "Deploying to $Env/$Reg..."
    
    $Path = "environments\$Env\$Reg"
    if (-not (Test-Path $Path)) {
        Write-Error "Path $Path does not exist"
        return $false
    }
    
    # Setup configuration files
    if (-not (Setup-EnvironmentConfig $Env $Reg)) {
        Write-Error "Failed to setup configuration for $Env/$Reg"
        return $false
    }
    
    Push-Location $Path
    try {
        # Initialize Terraform
        Write-Info "Initializing Terraform..."
        terraform init
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Terraform init failed for $Env/$Reg"
            return $false
        }
        
        # Plan Terraform
        Write-Info "Planning Terraform..."
        terraform plan -var-file=terraform.tfvars
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Terraform plan failed for $Env/$Reg"
            return $false
        }
        
        # Apply Terraform
        Write-Info "Applying Terraform..."
        terraform apply -var-file=terraform.tfvars -auto-approve
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Deployment to $Env/$Reg completed"
            return $true
        } else {
            Write-Error "Terraform apply failed for $Env/$Reg"
            return $false
        }
    } catch {
        Write-Error "Deployment to $Env/$Reg failed: $($_.Exception.Message)"
        return $false
    } finally {
        Pop-Location
    }
}

function Destroy-Environment {
    param([string]$Env, [string]$Reg)
    
    Write-Warning "Destroying $Env/$Reg..."
    
    $Path = "environments\$Env\$Reg"
    if (-not (Test-Path $Path)) {
        Write-Error "Path $Path does not exist"
        return $false
    }
    
    Push-Location $Path
    try {
        terraform destroy -var-file=terraform.tfvars -auto-approve
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Destruction of $Env/$Reg completed"
            return $true
        } else {
            Write-Error "Terraform destroy failed for $Env/$Reg"
            return $false
        }
    } catch {
        Write-Error "Destruction of $Env/$Reg failed: $($_.Exception.Message)"
        return $false
    } finally {
        Pop-Location
    }
}

function Test-Environment {
    param([string]$Env, [string]$Reg)
    
    Write-Info "Testing $Env/$Reg..."
    
    # Test LocalStack health
    $HealthCheck = Test-EnvironmentHealth $Env
    
    # Test LLM Router if deployed
    $Port = $PortMap[$Env]
    try {
        $TestPayload = @{
            user_id = "test-user"
            query = "Generate a simple VPC configuration"
            preferred_provider = "claude"
        } | ConvertTo-Json
        
        $Response = Invoke-RestMethod -Uri "http://localhost:$Port/llm-router" -Method Post -Body $TestPayload -ContentType "application/json" -TimeoutSec 10
        Write-Success "LLM Router test passed for $Env"
    } catch {
        Write-Warning "LLM Router not responding for $Env (may not be deployed yet)"
    }
    
    return $HealthCheck
}

function Clean-Environment {
    Write-Warning "Cleaning up all Terraform state and Docker volumes..."
    
    $Confirmation = Read-Host "This will remove ALL Terraform state and Docker volumes. Are you sure? (y/N)"
    if ($Confirmation -eq "y" -or $Confirmation -eq "Y") {
        # Stop all containers
        Stop-Environment "all"
        
        # Remove Terraform state files
        Get-ChildItem -Path "environments" -Recurse -Include "*.tfstate*" | Remove-Item -Force
        Get-ChildItem -Path "environments" -Recurse -Directory -Name ".terraform" | ForEach-Object {
            Remove-Item -Path $_ -Recurse -Force
        }
        
        # Clean Docker volumes
        docker volume prune -f
        
        Write-Success "Cleanup completed"
    } else {
        Write-Info "Operation cancelled"
    }
}

# Main execution logic
Write-Info "Enhanced Multi-Environment LocalStack Manager"
Write-Info "Action: $Action | Environment: $Environment | Region: $Region"
Write-Info ""

switch ($Action) {
    "start" {
        Start-Environment $Environment
    }
    "stop" {
        Stop-Environment $Environment
    }
    "status" {
        if ($Environment -eq "all") {
            Write-Info "=== LocalStack Environment Status ==="
            foreach ($Env in $Environments) {
                Test-EnvironmentHealth $Env | Out-Null
            }
        } else {
            Test-EnvironmentHealth $Environment | Out-Null
        }
    }
    "deploy" {
        $EnvsToProcess = if ($Environment -eq "all") { $Environments } else { @($Environment) }
        $RegsToProcess = if ($Region -eq "all") { $Regions } else { @($Region) }
        
        $SuccessCount = 0
        $TotalCount = $EnvsToProcess.Count * $RegsToProcess.Count
        
        foreach ($Env in $EnvsToProcess) {
            foreach ($Reg in $RegsToProcess) {
                if (Deploy-Environment $Env $Reg) {
                    $SuccessCount++
                }
            }
        }
        
        Write-Info ""
        Write-Info "Deployment Summary: $SuccessCount/$TotalCount successful"
    }
    "destroy" {
        $EnvsToProcess = if ($Environment -eq "all") { $Environments } else { @($Environment) }
        $RegsToProcess = if ($Region -eq "all") { $Regions } else { @($Region) }
        
        $Confirmation = Read-Host "Are you sure you want to destroy $Environment/$Region? (y/N)"
        if ($Confirmation -eq "y" -or $Confirmation -eq "Y") {
            foreach ($Env in $EnvsToProcess) {
                foreach ($Reg in $RegsToProcess) {
                    Destroy-Environment $Env $Reg
                }
            }
        } else {
            Write-Info "Operation cancelled"
        }
    }
    "test" {
        $EnvsToProcess = if ($Environment -eq "all") { $Environments } else { @($Environment) }
        $RegsToProcess = if ($Region -eq "all") { $Regions } else { @($Region) }
        
        foreach ($Env in $EnvsToProcess) {
            foreach ($Reg in $RegsToProcess) {
                Test-Environment $Env $Reg
            }
        }
    }
    "clean" {
        Clean-Environment
    }
}

Write-Info ""
Write-Info "Operation completed."
