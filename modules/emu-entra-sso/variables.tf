variable "enabled" {
  description = "Enable GitHub EMU Entra ID OIDC SSO (set false on Forgejo branch)"
  type        = bool
  default     = true
}

variable "display_name" {
  type    = string
  default = "GitHub Enterprise Managed User (OIDC)"
}

variable "scim_endpoint" {
  type      = string
  sensitive = true
}

variable "scim_token" {
  type      = string
  sensitive = true
}
