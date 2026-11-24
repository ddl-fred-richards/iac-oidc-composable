variable "oidc_issuer" {
  description = "Normalized OIDC issuer contract for JFrog Platform"
  type = object({
    name          = string
    provider_type = string # "GitHub", "GitHubEnterprise", or "generic" (Forgejo)
    url           = string
    audience      = string
    organization  = optional(string, null)
  })
}

variable "identity_mappings" {
  description = "Map of JFrog OIDC identity mappings ordered by priority (1 = highest)"
  type = map(object({
    priority   = number
    claims     = map(string)
    scope      = string
    expires_in = optional(number, 600)
    audience   = optional(string, "*@*")
    username   = optional(string, null)
  }))
}
