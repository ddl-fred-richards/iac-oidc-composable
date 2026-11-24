variable "identity_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "oidc_issuer" {
  description = "Normalized OIDC issuer contract"
  type = object({
    name     = string
    url      = string
    audience = optional(string, "api://AzureADTokenExchange")
  })
}

variable "federated_subjects" {
  description = "Map of credential names to exact OIDC sub claims (Entra does not allow wildcards)"
  type        = map(string)
}
