resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_federated_identity_credential" "this" {
  for_each = var.federated_subjects

  name                = "${var.oidc_issuer.name}-${each.key}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.this.id
  audience            = [var.oidc_issuer.audience]
  issuer              = var.oidc_issuer.url
  subject             = each.value
}
