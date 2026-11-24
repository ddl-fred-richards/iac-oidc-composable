variable "oidc_issuer" {
  description = "Normalized OIDC issuer contract for Auth0 Custom Token Exchange"
  type = object({
    name             = string
    url              = string
    jwks_uri         = string
    audience         = string
    allowed_repo_pfx = string
    allowed_ref      = string
  })
}

variable "subject_token_type" {
  description = "Custom URN sent by CI in /oauth/token subject_token_type"
  type        = string
  default     = "urn:ci:oidc:jwt"
}

variable "service_account_user_id" {
  description = "Auth0 user_id representing the CI workload identity"
  type        = string
}

variable "target_api_identifier" {
  description = "Auth0 API audience the CI job will call (must allow skipping user consent)"
  type        = string
}
