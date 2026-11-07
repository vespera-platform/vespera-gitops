variable "cloudflare_api_token" {
  type      = string
  sensitive = true
  ephemeral = true
}

resource "aws_secretsmanager_secret" "cloudflare" {
  name                    = "vespera/staging/cloudflare"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "cloudflare" {
  secret_id                = aws_secretsmanager_secret.cloudflare.id
  secret_string_wo         = jsonencode({ token = var.cloudflare_api_token })
  secret_string_wo_version = 1
}