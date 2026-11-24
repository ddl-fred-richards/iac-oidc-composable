data "azuread_application_template" "github_emu" {
  count        = var.enabled ? 1 : 0
  display_name = "GitHub Enterprise Managed User (OIDC)"
}

resource "azuread_application_from_template" "emu" {
  count        = var.enabled ? 1 : 0
  display_name = var.display_name
  template_id  = data.azuread_application_template.github_emu[0].template_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "azuread_synchronization_secret" "emu_scim" {
  count                = var.enabled ? 1 : 0
  service_principal_id = azuread_application_from_template.emu[0].service_principal_object_id

  credential {
    key   = "BaseAddress"
    value = var.scim_endpoint
  }
  credential {
    key   = "SecretToken"
    value = var.scim_token
  }
}

resource "azuread_synchronization_job" "emu_scim" {
  count                = var.enabled ? 1 : 0
  service_principal_id = azuread_application_from_template.emu[0].service_principal_object_id
  template_id          = "GitHubEnterpriseManagedUser"
  enabled              = true

  depends_on = [azuread_synchronization_secret.emu_scim]
}
