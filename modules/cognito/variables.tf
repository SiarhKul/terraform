variable "user_pool_name" {
  description = "The name of the user pool"
  type        = string
}

variable "domain" {
  description = "Cognito User Pool domain"
  type        = string
}

variable "allow_admin_create_user_only" {
  description = "Set to True if only the administrator is allowed to create user profiles. Set to False if users can sign themselves up via an app"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A mapping of tags to assign to the User Pool"
  type        = map(string)
  default     = {}
}

variable "mfa_configuration" {
  description = "Set to enable multi-factor authentication. Must be one of the following values (ON, OFF, OPTIONAL)"
  type        = string
  default     = "OFF"
}

variable "resource_servers" {
  description = "A list of resource server configurations"
  type        = list(any)
  default     = []
}

variable "clients" {
  description = "A list of client configurations"
  type        = list(any)
  default     = []
}
