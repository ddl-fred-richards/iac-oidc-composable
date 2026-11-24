variable "oidc_issuer" {
  description = "Normalized OIDC issuer contract (GitHub or Forgejo)"
  type = object({
    url           = string
    audiences     = list(string)
    subject_claim = optional(string, "sub")
  })
}

variable "role_name" {
  description = "IAM Role name assumed by CI workloads"
  type        = string
}

variable "allowed_subjects" {
  description = "List of StringLike patterns matched against the sub claim"
  type        = list(string)
}

variable "extra_claim_conditions" {
  description = "Optional extra OIDC claims (e.g., GitHub custom properties). Ignored if empty."
  type        = map(list(string))
  default     = {}
}
