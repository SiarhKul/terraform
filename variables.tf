# Input variables for the Cognito User Pool configuration

variable "environment_name" {
  description = "The name of the environment"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment_name)
    error_message = "The environment_name must be one of: dev, test, prod."
  }
}

variable "aws_region" {
  description = "The AWS region to deploy resources to"
  type        = string
  default     = "us-east-1"
}

variable "user_pool_name_prefix" {
  description = "Prefix for the Cognito User Pool name"
  type        = string
  default     = "machine-to-machine"
}

variable "domain_prefix" {
  description = "Prefix for the Cognito domain name"
  type        = string
  default     = "m2m-rubicon"
}

variable "project_tag" {
  description = "Value for the Project tag"
  type        = string
  default     = "m2m-auth"
}
