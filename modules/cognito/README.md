# Cognito User Pool Module

This module creates an AWS Cognito User Pool with configurable settings for authentication, authorization, and client applications.

## Features

- Creates a Cognito User Pool with customizable settings
- Supports resource servers with custom scopes
- Configures client applications with OAuth flows
- Provides outputs for integration with other services

## Usage

```hcl
module "cognito" {
  source = "./modules/cognito"
  
  user_pool_name = "my-user-pool"
  domain = "my-auth-domain"
  allow_admin_create_user_only = true
  
  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
  
  mfa_configuration = "OFF"
  
  resource_servers = [
    {
      identifier = "auth-resource-server"
      name       = "Auth Resource Server"
      scope = [
        {
          scope_name        = "read"
          scope_description = "Read access"
        }
      ]
    }
  ]
  
  clients = [
    {
      name                             = "my-client"
      allowed_oauth_flows              = ["client_credentials"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes             = ["auth-resource-server/read"]
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
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| user_pool_name | The name of the user pool | `string` | n/a | yes |
| domain | Cognito User Pool domain | `string` | n/a | yes |
| allow_admin_create_user_only | Set to True if only the administrator is allowed to create user profiles | `bool` | `true` | no |
| tags | A mapping of tags to assign to the User Pool | `map(string)` | `{}` | no |
| mfa_configuration | Set to enable multi-factor authentication (ON, OFF, OPTIONAL) | `string` | `"OFF"` | no |
| resource_servers | A list of resource server configurations | `list(any)` | `[]` | no |
| clients | A list of client configurations | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cognito_user_pool_id | The ID of the Cognito User Pool |
| cognito_app_client_id | The ID of the Cognito User Pool Client |
| cognito_app_client_secret | The client secret of the Cognito User Pool Client |
| cognito_domain | The domain of the Cognito User Pool |
| token_endpoint | The token endpoint of the Cognito User Pool |
