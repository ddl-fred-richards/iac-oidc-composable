locals {
  zot_config = {
    distSpecVersion = "1.1.0"
    storage = {
      rootDirectory = "/var/lib/registry"
    }
    http = {
      address = "0.0.0.0"
      port    = "5000"
      auth = {
        bearer = {
          oidc = [
            {
              name         = var.oidc_issuer.name
              issuer       = var.oidc_issuer.url
              audiences    = var.oidc_issuer.audiences
              claimMapping = var.claim_mapping
              validations  = var.cel_validations
            }
          ]
        }
      }
      accessControl = {
        repositories = var.zot_rbac_policies
      }
    }
  }

  zot_config_json = jsonencode(local.zot_config)
}

resource "kubernetes_config_map_v1" "zot_config" {
  count = var.create_configmap ? 1 : 0

  metadata {
    name      = "zot-config"
    namespace = var.namespace
  }

  data = {
    "config.json" = local.zot_config_json
  }
}
