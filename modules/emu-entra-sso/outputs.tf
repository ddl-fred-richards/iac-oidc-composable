output "service_principal_object_id" {
  value = var.enabled ? azuread_application_from_template.emu[0].service_principal_object_id : null
}
