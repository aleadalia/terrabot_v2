# TerraBot Quick Start Guide

## Project Overview
A minimal yet functional Discord bot on AWS Lambda using Terraform. This setup focuses on getting you up and running quickly with essential features.

## Core Components
1. **AWS Lambda** - Runs the bot code
2. **API Gateway** - Receives Discord webhooks
3. **DynamoDB** - Simple data storage (optional, can be added later)
4. **IAM** - Minimal required permissions

## Quick Start

### 1. Prerequisites
- [AWS Account](https://aws.amazon.com/)
- [Terraform](https://www.terraform.io/downloads.html) (latest)
- [Python 3.9+](https://www.python.org/downloads/)
- [AWS CLI](https://aws.amazon.com/cli/) configured
- [Discord Developer Account](https://discord.com/developers/applications)

### 2. Project Setup
```bash
# Create project directory
mkdir terrabotv2
cd terrabotv2

# Initialize git (optional but recommended)
git init

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
.\venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# Install Python requirements
echo "discord.py>=2.0.0" > requirements.txt
pip install -r requirements.txt
```

### 3. Configure Discord Bot
1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Create New Application
3. Go to "Bot" tab and click "Add Bot"
4. Copy the bot token (keep this secret!)
5. Under "Privileged Gateway Intents", enable all intents

### 4. Set Up Environment Variables
Create a file named `.env` in your project root:
```
DISCORD_TOKEN=your_bot_token_here
DISCORD_PUBLIC_KEY=your_public_key_here
DISCORD_APPLICATION_ID=your_application_id_here
```

### 5. Create Basic Bot Code
Create `bot.py`:
```python
import os
import json
import logging
import discord
from discord import app_commands

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize Discord client
intents = discord.Intents.default()
intents.message_content = True
client = discord.Client(intents=intents)
tree = app_commands.CommandTree(client)

@client.event
async def on_ready():
    await tree.sync()
    logging.info(f'Logged in as {client.user} (ID: {client.user.id})')

@tree.command(name="ping", description="Check if bot is alive")
async def ping(interaction: discord.Interaction):
    await interaction.response.send_message("Pong! 🏓")

def lambda_handler(event, context):
    # This will be used by Lambda
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }

# Local development
if __name__ == "__main__":
    client.run(os.getenv('DISCORD_TOKEN'))
```

### 6. Create Terraform Configuration

1. Create a `terraform` directory and `main.tf`:

```hcl
# terraform/main.tf
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Lambda function
resource "aws_lambda_function" "discord_bot" {
  function_name = "discord-bot"
  handler       = "bot.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "${path.module}/../deploy_package.zip"
  
  environment {
    variables = {
      DISCORD_TOKEN      = var.discord_token
      DISCORD_PUBLIC_KEY = var.discord_public_key
    }
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "discord-bot-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# API Gateway
resource "aws_apigatewayv2_api" "discord_webhook" {
  name          = "discord-webhook"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.discord_webhook.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "discord_bot" {
  api_id             = aws_apigatewayv2_api.discord_webhook.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.discord_bot.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "discord_webhook" {
  api_id    = aws_apigatewayv2_api.discord_webhook.id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.discord_bot.id}"
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.discord_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.discord_webhook.execution_arn}/*/*"
}

# Output the API Gateway URL
output "api_gateway_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
```

2. Create `variables.tf`:
```hcl
variable "discord_token" {
  description = "Discord bot token"
  type        = string
  sensitive   = true
}

variable "discord_public_key" {
  description = "Discord public key"
  type        = string
  sensitive   = true
}
```

3. Create `outputs.tf`:
```hcl
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_stage.default.invoke_url
}
```

### 7. Create Deployment Script

Create a file named `deploy.ps1` (Windows) or `deploy.sh` (Linux/Mac):

```powershell
# deploy.ps1 for Windows
# Install dependencies
pip install -r requirements.txt -t ./package

# Create deployment package
Compress-Archive -Path .\package\*, .\bot.py -DestinationPath .\deploy_package.zip -Force

# Initialize and apply Terraform
cd terraform
terraform init
terraform apply -var="discord_token=$env:DISCORD_TOKEN" -var="discord_public_key=$env:DISCORD_PUBLIC_KEY" -auto-approve

# Get the API Gateway URL
$api_url = terraform output -raw api_endpoint
Write-Host "API Gateway URL: $api_url"
Write-Host "Set this as your Discord Interactions Endpoint URL in the Developer Portal"
```

### 8. Deploy Your Bot

1. Run the deployment script:
```bash
# Windows
.\deploy.ps1

# Linux/Mac
chmod +x deploy.sh
./deploy.sh
```

2. Copy the API Gateway URL from the output
3. Go to your Discord Developer Portal > Your Application > General Information
4. Set the Interactions Endpoint URL to your API Gateway URL
5. Save changes

## Testing Your Bot

1. Invite your bot to a server using this URL (replace CLIENT_ID with your bot's client ID):
   ```
   https://discord.com/api/oauth2/authorize?client_id=YOUR_CLIENT_ID&permissions=0&scope=bot%20applications.commands
   ```

2. In your Discord server, type `/ping` to test the bot

## Next Steps

1. Add more commands by adding new `@tree.command` decorators in `bot.py`
2. Add error handling and logging
3. Set up monitoring with CloudWatch
4. Add CI/CD pipeline with GitHub Actions

## Troubleshooting

- **Bot not responding**: Check CloudWatch logs for errors
- **401 Unauthorized**: Verify your Discord public key and token are correct
- **504 Timeout**: Check if your Lambda function is timing out (default is 3 seconds)

## Clean Up

To remove all AWS resources:
```bash
cd terraform
terraform destroy -var="discord_token=$env:DISCORD_TOKEN" -var="discord_public_key=$env:DISCORD_PUBLIC_KEY" -auto-approve
```

## Support

For help, open an issue in the repository or check the [Discord.py documentation](https://discordpy.readthedocs.io/).
