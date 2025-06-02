module "cognito_user_pool" {
  source  = "lgallard/cognito-user-pool/aws"
  user_pool_name = var.user_pool_name
  domain = var.domain

  admin_create_user_config = {
    allow_admin_create_user_only = var.allow_admin_create_user_only
  }

  tags = var.tags

  mfa_configuration = var.mfa_configuration

  resource_servers = var.resource_servers

  clients = var.clients
}
