provider "aws" {
  region = var.aws_region
}

locals {
  is_prod_environment = var.environment_name == "prod"
  domain_name         = local.is_prod_environment ? "${var.domain_prefix}-auth" : "${var.domain_prefix}-${var.environment_name}-auth"
}

resource "aws_cognito_user_pool" "m2m_user_pool" {
  name = "${var.environment_name}-${var.user_pool_name_prefix}-user-pool"

  tags = {
    Environment    = var.environment_name
    Project        = var.project_tag
    Terraform      = "true"
    CloudFormation = "false"
    Type           = "M2M"
  }
}

resource "aws_cognito_resource_server" "m2m_resource_server" {
  identifier   = "m2m-client"
  name         = "User API"
  user_pool_id = aws_cognito_user_pool.m2m_user_pool.id

  scope {
    scope_name        = "write"
    scope_description = "Write access"
  }

  scope {
    scope_name        = "read"
    scope_description = "Read access"
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = "m2m-client"
  user_pool_id                         = aws_cognito_user_pool.m2m_user_pool.id
  generate_secret                      = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                = [
    "${aws_cognito_resource_server.m2m_resource_server.identifier}/read",
    "${aws_cognito_resource_server.m2m_resource_server.identifier}/write"
  ]
  allowed_oauth_flows_user_pool_client = true
  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = ["https://example.com/callback"] # обязательное поле

  refresh_token_validity       = 30
  access_token_validity        = 1
  id_token_validity            = 1

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Prevent user existence errors for M2M authentication
  prevent_user_existence_errors = "ENABLED"

  depends_on = [aws_cognito_resource_server.m2m_resource_server]
}

# Cognito User Pool Domain - For M2M token endpoint
resource "aws_cognito_user_pool_domain" "m2m_domain" {
  domain          = local.domain_name
  user_pool_id    = aws_cognito_user_pool.m2m_user_pool.id
  managed_login_version = 2
}

# Get current region
data "aws_region" "current" {}
