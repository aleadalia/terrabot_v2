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
  timeout       = 10  # 10 seconds timeout
  
  environment {
    variables = {
      DISCORD_TOKEN      = var.discord_token
      DISCORD_PUBLIC_KEY = var.discord_public_key
    }
  }

  # Enable function URL
  publish = true
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

# API Gateway REST API
resource "aws_api_gateway_rest_api" "discord_webhook" {
  name        = "discord-webhook"
  description = "REST API for Discord bot webhooks"
}

resource "aws_api_gateway_method" "discord_webhook" {
  rest_api_id   = aws_api_gateway_rest_api.discord_webhook.id
  resource_id   = aws_api_gateway_rest_api.discord_webhook.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "discord_bot" {
  rest_api_id = aws_api_gateway_rest_api.discord_webhook.id
  resource_id = aws_api_gateway_rest_api.discord_webhook.root_resource_id
  http_method = aws_api_gateway_method.discord_webhook.http_method
  
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.discord_bot.invoke_arn
}

resource "aws_api_gateway_deployment" "discord_webhook" {
  depends_on = [
    aws_api_gateway_integration.discord_bot,
    aws_api_gateway_integration.options
  ]
  
  rest_api_id = aws_api_gateway_rest_api.discord_webhook.id
  stage_name  = "prod"
  
  # Forzar nuevo despliegue en cada cambio
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.discord_bot,
      aws_api_gateway_method.discord_webhook,
      aws_api_gateway_method.options
    ]))
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Enable CORS
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.discord_webhook.id
  resource_id   = aws_api_gateway_rest_api.discord_webhook.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.discord_webhook.id
  resource_id = aws_api_gateway_rest_api.discord_webhook.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.discord_webhook.id
  resource_id = aws_api_gateway_rest_api.discord_webhook.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.discord_webhook.id
  resource_id = aws_api_gateway_rest_api.discord_webhook.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Signature-Ed25519,X-Signature-Timestamp'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.discord_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.discord_webhook.execution_arn}/*/${aws_api_gateway_method.discord_webhook.http_method}/"
}

# Output the API Gateway URL
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = "${aws_api_gateway_deployment.discord_webhook.invoke_url}"
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.discord_bot.function_name
}
