output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = module.cognito_user_pool.id
}

output "cognito_app_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = module.cognito_user_pool.client_ids[0]
}

output "cognito_app_client_secret" {
  description = "The client secret of the Cognito User Pool Client"
  value       = module.cognito_user_pool.client_secrets[0]
  sensitive   = true
}

# https://auth-api-app-mercell-com.amazoncognito.com/oauth2/token
// https://auth.api.app.mercell.com
output "cognito_domain" {
  description = "The domain of the Cognito User Pool"
  value       = "https://${var.domain}.amazoncognito.com"
}

output "token_endpoint" {
  description = "The token endpoint of the Cognito User Pool"
  value       = "https://auth.api.app.mercell.${var.domain}/oauth2/token"
}
