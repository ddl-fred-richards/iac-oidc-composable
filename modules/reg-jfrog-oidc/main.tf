locals {
  is_github = contains(["GitHub", "GitHubEnterprise"], var.oidc_issuer.provider_type)
}

resource "platform_oidc_configuration" "this" {
  name          = var.oidc_issuer.name
  description   = "Managed OIDC trust for ${var.oidc_issuer.name}"
  provider_type = var.oidc_issuer.provider_type
  issuer_url    = var.oidc_issuer.url
  audience      = var.oidc_issuer.audience

  organization                    = local.is_github ? var.oidc_issuer.organization : null
  enable_permissive_configuration = var.oidc_issuer.provider_type == "GitHub" ? false : null
}

resource "platform_oidc_identity_mapping" "this" {
  for_each = var.identity_mappings

  name          = each.key
  provider_name = platform_oidc_configuration.this.name
  priority      = each.value.priority
  claims_json   = jsonencode(each.value.claims)

  token_spec = {
    scope      = each.value.scope
    expires_in = each.value.expires_in
    audience   = each.value.audience
    username   = each.value.username
  }
}
