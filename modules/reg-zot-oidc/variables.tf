variable "namespace" {
  type = string
}

variable "create_configmap" {
  description = "Set false to render config.json output only without writing to a cluster"
  type        = bool
  default     = true
}

variable "oidc_issuer" {
  type = object({
    name      = string
    url       = string
    audiences = list(string)
  })
}

variable "cel_validations" {
  description = "CEL expressions evaluated against incoming JWT claims"
  type = list(object({
    expression = string
    message    = string
  }))
}

variable "claim_mapping" {
  description = "Maps OIDC JWT claims to Zot username/groups for RBAC"
  type = object({
    username = string
    groups   = optional(string, "repository_owner")
  })
}

variable "zot_rbac_policies" {
  description = "Zot accessControl.repositories block"
  type        = any
}
