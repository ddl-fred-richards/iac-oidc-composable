output "auth0_client_id" {
  value = auth0_client.ci_exchange_client.client_id
}

output "token_exchange_profile_id" {
  value = auth0_token_exchange_profile.ci_oidc.id
}
