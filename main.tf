# AWS Provider configuration
provider "aws" {
  region = var.aws_region

  # Authentication can be provided via:
  # 1. Environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN)
  # 2. Shared credentials file (~/.aws/credentials)
  # 3. EC2 instance profile or ECS task role
  # 4. Explicitly defined credentials (uncomment and replace with your credentials if needed)
  # access_key = "your-access-key"
  # secret_key = "your-secret-key"
  # token      = "your-session-token"  # Only needed for temporary credentials

  # If you're experiencing the "InvalidClientTokenId" error, try one of these solutions:
  # - Run 'aws configure' to set up your credentials
  # - Set environment variables: export AWS_ACCESS_KEY_ID="..." AWS_SECRET_ACCESS_KEY="..."
  # - Verify your credentials with: aws sts get-caller-identity
  # - Uncomment and set the access_key and secret_key above (for testing only)
}

# Local variables
locals {
  is_prod_environment = var.environment_name == "prod"
  domain_name         = local.is_prod_environment ? "${var.domain_prefix}-auth" : "${var.domain_prefix}-${var.environment_name}-auth"
}

# Cognito User Pool
resource "aws_cognito_user_pool" "m2m_user_pool" {
  name = "${var.environment_name}-${var.user_pool_name_prefix}-user-pool"

  # Removed email attributes for pure M2M configuration

  tags = {
    Environment    = var.environment_name
    Project        = var.project_tag
    Terraform      = "true"
    CloudFormation = "false"
  }
}

# Cognito Resource Server
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

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "dealwise_client" {
  name                         = "dealwise-client"
  user_pool_id                 = aws_cognito_user_pool.m2m_user_pool.id
  generate_secret              = true
  refresh_token_validity       = 30
  access_token_validity        = 1
  id_token_validity            = 1

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["m2m-client/read", "m2m-client/write"]

  # Only refresh token auth is needed for M2M
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  depends_on = [aws_cognito_resource_server.m2m_resource_server]
}

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "m2m_domain" {
  domain          = local.domain_name
  user_pool_id    = aws_cognito_user_pool.m2m_user_pool.id
  managed_login_version = 2
}

# Get current region
data "aws_region" "current" {}
