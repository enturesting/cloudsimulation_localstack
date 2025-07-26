#!/usr/bin/env pwsh
# Root-level LocalStack Pro management convenience script
# Points to the organized scripts in scripts/localstack-pro/

param(
    [Parameter(Position=0)]
    [string]$Action = "help"
)

# Call the main organized management script
& "$PSScriptRoot\scripts\localstack-pro\localstack.ps1" $Action
