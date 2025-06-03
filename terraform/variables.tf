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

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
