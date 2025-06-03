# 🤖 TerraBot - Serverless Discord Bot

A lightweight, serverless Discord bot deployed on AWS Lambda using Terraform. Get started quickly with minimal setup.

## 🚀 Quick Start

### Prerequisites
- [AWS Account](https://aws.amazon.com/)
- [Terraform](https://www.terraform.io/downloads.html)
- [Python 3.9+](https://www.python.org/downloads/)
- [AWS CLI](https://aws.amazon.com/cli/) configured
- [Discord Developer Account](https://discord.com/developers/applications)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/terrabotv2.git
   cd terrabotv2
   ```

2. **Set up Python environment**
   ```bash
   python -m venv venv
   .\venv\Scripts\activate  # Windows
   # OR
   source venv/bin/activate  # Mac/Linux
   
   pip install -r requirements.txt
   ```

3. **Configure Discord Bot**
   - Create a new application at [Discord Developer Portal](https://discord.com/developers/applications)
   - Create a bot and copy the token
   - Enable all intents

4. **Configure Environment**
   Create `.env` file:
   ```
   DISCORD_TOKEN=your_bot_token_here
   DISCORD_PUBLIC_KEY=your_public_key_here
   DISCORD_APPLICATION_ID=your_application_id_here
   ```

### 🚀 Deploy

1. **Deploy to AWS**
   ```bash
   # Windows
   .\deploy.ps1
   
   # Linux/Mac
   chmod +x deploy.sh
   ./deploy.sh
   ```

2. **Set Discord Webhook**
   - Copy the API Gateway URL from the output
   - Go to Discord Developer Portal > Your App > General Information
   - Set "Interactions Endpoint URL" to your API Gateway URL

### 🤖 Test Your Bot

1. Invite the bot to your server:
   ```
   https://discord.com/api/oauth2/authorize?client_id=YOUR_CLIENT_ID&permissions=0&scope=bot%20applications.commands
   ```

2. Try the command:
   ```
   /ping
   ```

## 📁 Project Structure

```
terrabotv2/
├── bot.py               # Main bot code
├── requirements.txt     # Python dependencies
├── .env                # Environment variables
├── deploy.ps1          # Windows deployment script
├── deploy.sh           # Linux/Mac deployment script
└── terraform/          # Infrastructure as Code
    ├── main.tf         # Main Terraform config
    ├── variables.tf    # Variable definitions
    └── outputs.tf      # Output configurations
```

## 🛠️ Adding Commands

Edit `bot.py` to add new slash commands:

```python
@tree.command(name="hello", description="Say hello")
async def hello(interaction: discord.Interaction):
    await interaction.response.send_message(f"Hello {interaction.user.mention}!")
```

## 🔧 Troubleshooting

- **Bot not responding?** Check CloudWatch logs in AWS Console
- **401 Unauthorized?** Verify your Discord public key and token
- **Deployment issues?** Run `terraform init` and try again

## 🧹 Clean Up

To remove all AWS resources:
```bash
cd terraform
terraform destroy -var="discord_token=$env:DISCORD_TOKEN" -var="discord_public_key=$env:DISCORD_PUBLIC_KEY" -auto-approve
```

## 📚 Learn More

- [Discord.py Documentation](https://discordpy.readthedocs.io/)
- [AWS Lambda with Python](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
