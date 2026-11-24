variable "enabled" {
  description = "Enable GitHub Org OIDC subject claim customization (set false for Forgejo)"
  type        = bool
  default     = true
}

variable "include_claim_keys" {
  description = "List of claim keys to include in GitHub Actions OIDC sub claim"
  type        = list(string)
  default     = ["repo", "context", "repo_property_tier"]
}
