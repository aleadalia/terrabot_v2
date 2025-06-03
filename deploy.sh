#!/bin/bash

# Check if .env exists
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please create one based on .env.example"
    exit 1
fi

# Load environment variables
export $(grep -v '^#' .env | xargs)

# Install dependencies
echo "🚀 Installing Python dependencies..."
mkdir -p package
pip install -r requirements.txt -t ./package

# Copy bot.py to package
cp bot.py ./package/

# Create deployment package
echo "📦 Creating deployment package..."
if [ -f deploy_package.zip ]; then
    rm deploy_package.zip
fi

cd package
zip -r ../deploy_package.zip .
cd ..

# Clean up
rm -rf package

# Deploy with Terraform
echo "🚀 Deploying to AWS..."
cd terraform

# Initialize Terraform if not already initialized
if [ ! -d .terraform ]; then
    terraform init
fi

# Apply Terraform
export TF_VAR_discord_token=$DISCORD_TOKEN
export TF_VAR_discord_public_key=$DISCORD_PUBLIC_KEY

terraform apply -auto-approve

# Get the API Gateway URL
api_url=$(terraform output -raw api_endpoint)
echo ""
echo "✅ Deployment complete!"
echo "🔗 API Gateway URL: $api_url"
echo ""
echo "📝 Set this as your Discord Interactions Endpoint URL in the Developer Portal:"
echo "   $api_url"
echo ""
echo "🤖 Invite your bot to a server using this URL (replace YOUR_CLIENT_ID):"
echo "   https://discord.com/api/oauth2/authorize?client_id=YOUR_CLIENT_ID&permissions=0&scope=bot%20applications.commands"
echo ""
