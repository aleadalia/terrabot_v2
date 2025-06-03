# Check if .env exists
if (-not (Test-Path .\.env)) {
    Write-Error "Error: .env file not found. Please create one based on .env.example"
    exit 1
}

# Load environment variables
Get-Content .\.env | ForEach-Object {
    $name, $value = $_.split('=')
    if ($name -and $value) {
        [System.Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
}

# Install dependencies
Write-Host "🚀 Installing Python dependencies..."
pip install -r requirements.txt -t .\package

# Copy bot.py to package
Copy-Item .\bot.py .\package\

# Create deployment package
Write-Host "📦 Creating deployment package..."
if (Test-Path .\deploy_package.zip) {
    Remove-Item .\deploy_package.zip -Force
}
Compress-Archive -Path .\package\* -DestinationPath .\deploy_package.zip -Force

# Clean up
Remove-Item -Recurse -Force .\package -ErrorAction SilentlyContinue

# Deploy with Terraform
Write-Host "🚀 Deploying to AWS..."
Set-Location terraform

# Initialize Terraform if not already initialized
if (-not (Test-Path .\.terraform)) {
    terraform init
}

# Apply Terraform
$env:TF_VAR_discord_token = $env:DISCORD_TOKEN
$env:TF_VAR_discord_public_key = $env:DISCORD_PUBLIC_KEY

try {
    terraform apply -auto-approve
    $api_url = terraform output -raw api_endpoint
    
    Write-Host ""
    Write-Host "✅ Deployment complete!"
    Write-Host "🔗 API Gateway URL: $api_url"
    Write-Host ""
    Write-Host "📝 Set this as your Discord Interactions Endpoint URL in the Developer Portal:"
    Write-Host "   $api_url"
    Write-Host ""
    
    # Get application ID from .env
    $app_id = (Get-Content ..\.env | Where-Object { $_ -match '^DISCORD_APPLICATION_ID=' } -First 1).Split('=')[1]
    $base_url = "https://discord.com/api/oauth2/authorize"
    $params = "client_id=$app_id&permissions=0&scope=bot%20applications.commands"
    $invite_url = "$base_url`?$params"
    Write-Host "🤖 Invite your bot to a server using this URL:"
    Write-Host ("   {0}" -f $invite_url)
    Write-Host ""
} catch {
    Write-Error "❌ Error during deployment: $_"
    exit 1
}
