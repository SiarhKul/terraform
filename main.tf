terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "cognito_user_pool" {
  source  = "lgallard/cognito-user-pool/aws"
  version = "0.35.0"

  user_pool_name = "m2m-dev-terraform"

  admin_create_user_config = {
    allow_admin_create_user_only = true
  }

  tags = {
    Environment = "dev"
    Project     = "m2m-auth"
  }

  domain = "m2m-rubicon-dev"

  resource_servers = [
    {
      identifier = "auth-resource-server"
      name       = "Auth Resource Server"
      scopes = [
        {
          scope_name        = "custom-scope.read"
          scope_description = "Read access"
        }
      ]
    }
  ]


  clients = [
    {
      name                             = "machine-to-machine-client-dev"
      allowed_oauth_flows              = ["client_credentials"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes             = ["auth-resource-server/custom-scope.read"]
      generate_secret                  = true
      supported_identity_providers     = ["COGNITO"]
      explicit_auth_flows              = ["ALLOW_REFRESH_TOKEN_AUTH"]
      auth_session_validity            = 3
      refresh_token_validity           = 5
      access_token_validity            = 60
      id_token_validity                = 60
      token_validity_units = {
        refresh_token = "days"
        access_token  = "minutes"
        id_token      = "minutes"
      }
      enable_token_revocation = true
    }
  ]


}

output "cognito_user_pool_id" {
  value = module.cognito_user_pool.id
}

output "cognito_app_client_id" {
  value = module.cognito_user_pool.client_ids[0]
}

output "cognito_app_client_secret" {
  value     = module.cognito_user_pool.client_secrets[0]
  sensitive = true
}

output "cognito_domain" {
  value = "https://m2m-rubicon-dev.auth.us-east-1.amazoncognito.com"
}

output "token_endpoint" {
  value = "https://m2m-rubicon-dev.auth.us-east-1.amazoncognito.com/oauth2/token"
}
