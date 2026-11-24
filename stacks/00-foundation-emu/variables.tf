variable "git_provider" {
  type = string
  validation {
    condition     = contains(["github", "forgejo"], var.git_provider)
    error_message = "Supported providers: github, forgejo"
  }
}

variable "scim_endpoint" {
  type      = string
  default   = ""
  sensitive = true
}

variable "scim_token" {
  type      = string
  default   = ""
  sensitive = true
}
