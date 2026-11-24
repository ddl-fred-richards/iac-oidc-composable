module "emu_entra_sso" {
  source = "../../modules/emu-entra-sso"

  enabled       = var.git_provider == "github"
  scim_endpoint = var.scim_endpoint
  scim_token    = var.scim_token
}
