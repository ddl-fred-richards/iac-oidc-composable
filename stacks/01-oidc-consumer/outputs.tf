output "active_git_provider" {
  value = var.git_provider
}

output "aws_role_arn" {
  value = var.enable_aws ? module.aws_ci_role[0].role_arn : null
}

output "entra_client_id" {
  value = var.enable_entra ? module.entra_ci_identity[0].client_id : null
}

output "auth0_client_id" {
  value = var.enable_auth0 ? module.auth0_exchange[0].auth0_client_id : null
}

output "jfrog_provider_name" {
  value = var.enable_jfrog ? module.jfrog_registry[0].provider_name : null
}

output "zot_config_json" {
  value = var.enable_zot ? module.zot_registry[0].zot_config_json : null
}
