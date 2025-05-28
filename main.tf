provider "aws" {
  region = var.aws_region
}

resource "aws_cognito_user_pool" "cognito_m2m_pool" {
  name = "${var.user_pool_name_prefix}-${var.environment_name}"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  tags = {
    Environment = var.environment_name
    Project     = var.project_tag
  }
}

resource "aws_cognito_user_pool_domain" "cognito_m2m_pool_main_domain" {
  domain       = "${var.domain_prefix}-${var.environment_name}"
  user_pool_id = aws_cognito_user_pool.cognito_m2m_pool.id
}

resource "aws_cognito_resource_server" "resource_server" {
  identifier = "auth-resource-server"
  name       = "Auth Resource Server"

  scope {
    scope_name        = "custom-scope.read"
    scope_description = "Read access"
  }

  scope {
    scope_name        = "custom-scope.write"
    scope_description = "Write access"
  }

  user_pool_id = aws_cognito_user_pool.cognito_m2m_pool.id
}



resource "aws_cognito_user_pool_client" "cognito_m2m_pool_client" {
  name                = "${var.user_pool_name_prefix}-client-${var.environment_name}"
  user_pool_id        = aws_cognito_user_pool.cognito_m2m_pool.id
  depends_on          = [aws_cognito_resource_server.resource_server]
  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH"]
  auth_session_validity = 3
  refresh_token_validity = 5
  access_token_validity = 60
  id_token_validity = 60
  token_validity_units {
    refresh_token = "days"
    access_token = "minutes"
    id_token = "minutes"
  }
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["client_credentials"]
  allowed_oauth_scopes = [
    "auth-resource-server/custom-scope.write",
    "auth-resource-server/custom-scope.read"
  ]
  callback_urls = [var.callback_url]
  supported_identity_providers         = ["COGNITO"]
  generate_secret     = true
  enable_token_revocation = true
  prevent_user_existence_errors = "ENABLED"
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.cognito_m2m_pool.id
}

output "cognito_app_client_id" {
  value = aws_cognito_user_pool_client.cognito_m2m_pool_client.id
}

output "cognito_app_client_secret" {
  value     = aws_cognito_user_pool_client.cognito_m2m_pool_client.client_secret
  sensitive = true
}

output "cognito_domain" {
  value = "https://${aws_cognito_user_pool_domain.cognito_m2m_pool_main_domain.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "token_endpoint" {
  value = "https://${aws_cognito_user_pool_domain.cognito_m2m_pool_main_domain.domain}.auth.${var.aws_region}.amazoncognito.com/oauth2/token"
}
