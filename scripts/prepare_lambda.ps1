# Navigate to the Lambda function directory
Set-Location -Path "$PSScriptRoot/../modules/llm_router/v0.1.0/lambda"

# Install dependencies
Write-Host "Installing dependencies..."
npm install

# Ensure the output directory exists
$outputDir = "$PSScriptRoot/../lambda"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Create zip file in the correct location
Write-Host "Creating zip file..."
Compress-Archive -Path * -DestinationPath "$outputDir/llm-router.zip" -Force

# Return to original directory
Set-Location -Path "$PSScriptRoot/.."

Write-Host "Lambda function prepared successfully!" 