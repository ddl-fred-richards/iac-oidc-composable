variable "git_provider" {
  type = string
  validation {
    condition     = contains(["github", "forgejo"], var.git_provider)
    error_message = "Supported providers: github, forgejo"
  }
}

variable "org_name" {
  type    = string
  default = "my-org"
}

variable "repo_name" {
  type    = string
  default = "platform-infra"
}

variable "forgejo_base_url" {
  type    = string
  default = "https://forgejo.internal.example.com"
}

# Composable feature toggles
variable "enable_aws" {
  type    = bool
  default = true
}

variable "enable_entra" {
  type    = bool
  default = false
}

variable "enable_auth0" {
  type    = bool
  default = false
}

variable "enable_jfrog" {
  type    = bool
  default = false
}

variable "enable_zot" {
  type    = bool
  default = true
}

variable "zot_create_configmap" {
  description = "Set false to render zot_config_json locally without a K8s cluster"
  type        = bool
  default     = false
}

# Target-specific settings
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "azure_resource_group" {
  type    = string
  default = "rg-platform-oidc"
}

variable "azure_location" {
  type    = string
  default = "eastus2"
}

variable "jfrog_audience" {
  type    = string
  default = "https://jfrog.internal.example.com"
}

variable "zot_audience" {
  type    = string
  default = "https://zot.internal.example.com"
}

variable "auth0_exchange_audience" {
  type    = string
  default = "https://auth.example.com/ci-exchange"
}

variable "auth0_service_account_user_id" {
  type    = string
  default = "auth0|ci-platform-deployer"
}

variable "auth0_target_api" {
  type    = string
  default = "https://api.internal.example.com"
}
