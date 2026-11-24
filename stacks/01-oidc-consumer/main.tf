locals {
  oidc_profiles = {
    github = {
      name         = "github"
      url          = "https://token.actions.githubusercontent.com"
      jwks_uri     = "https://token.actions.githubusercontent.com/.well-known/jwks"
      aws_subjects = ["repo:${var.org_name}/*:environment:prod:repo_property_tier:prod"]
      entra_subjects = {
        "prod-env" = "repo:${var.org_name}/${var.repo_name}:environment:prod:repo_property_tier:prod"
      }
      jfrog_type   = "GitHub"
      jfrog_org    = var.org_name
      jfrog_claims = { repository = "${var.org_name}/${var.repo_name}", ref = "refs/heads/main" }
      zot_cel = [
        {
          expression = "claims.repository_owner == '${var.org_name}' && claims.ref == 'refs/heads/main'"
          message    = "Only main branch in ${var.org_name} may push to Zot"
        }
      ]
    }

    forgejo = {
      name         = "forgejo"
      url          = "${var.forgejo_base_url}/api/actions/oidc"
      jwks_uri     = "${var.forgejo_base_url}/api/actions/oidc/.well-known/jwks"
      aws_subjects = ["repo:${var.org_name}/*:ref:refs/heads/main"]
      entra_subjects = {
        "main-branch" = "repo:${var.org_name}/${var.repo_name}:ref:refs/heads/main"
      }
      jfrog_type   = "generic"
      jfrog_org    = null
      jfrog_claims = { repository = "${var.org_name}/${var.repo_name}", ref = "refs/heads/main" }
      zot_cel = [
        {
          expression = "claims.repository.startsWith('${var.org_name}/') && claims.ref == 'refs/heads/main'"
          message    = "Only main branch in ${var.org_name} Forgejo repos may push to Zot"
        }
      ]
    }
  }

  active_profile = local.oidc_profiles[var.git_provider]
}

module "github_oidc_claims" {
  source  = "../../modules/github-oidc-config"
  enabled = var.git_provider == "github"
}

module "aws_ci_role" {
  count     = var.enable_aws ? 1 : 0
  source    = "../../modules/idp-aws-oidc"
  role_name = "ci-prod-deployer-${var.git_provider}"

  oidc_issuer = {
    url       = local.active_profile.url
    audiences = ["sts.amazonaws.com"]
  }

  allowed_subjects = local.active_profile.aws_subjects
}

module "entra_ci_identity" {
  count               = var.enable_entra ? 1 : 0
  source              = "../../modules/idp-entra-oidc"
  identity_name       = "uami-ci-deployer-${var.git_provider}"
  resource_group_name = var.azure_resource_group
  location            = var.azure_location

  oidc_issuer = {
    name = local.active_profile.name
    url  = local.active_profile.url
  }

  federated_subjects = local.active_profile.entra_subjects
}

module "auth0_exchange" {
  count  = var.enable_auth0 ? 1 : 0
  source = "../../modules/idp-auth0-oidc"

  oidc_issuer = {
    name             = local.active_profile.name
    url              = local.active_profile.url
    jwks_uri         = local.active_profile.jwks_uri
    audience         = var.auth0_exchange_audience
    allowed_repo_pfx = "${var.org_name}/"
    allowed_ref      = "refs/heads/main"
  }

  service_account_user_id = var.auth0_service_account_user_id
  target_api_identifier   = var.auth0_target_api
}

module "jfrog_registry" {
  count  = var.enable_jfrog ? 1 : 0
  source = "../../modules/reg-jfrog-oidc"

  oidc_issuer = {
    name          = "ci-${local.active_profile.name}"
    provider_type = local.active_profile.jfrog_type
    url           = local.active_profile.url
    audience      = var.jfrog_audience
    organization  = local.active_profile.jfrog_org
  }

  identity_mappings = {
    "prod-publishers" = {
      priority   = 1
      claims     = local.active_profile.jfrog_claims
      scope      = "applied-permissions/groups:\"ci-publishers\""
      expires_in = 600
    }
  }
}

module "zot_registry" {
  count            = var.enable_zot ? 1 : 0
  source           = "../../modules/reg-zot-oidc"
  namespace        = "registry"
  create_configmap = var.zot_create_configmap

  oidc_issuer = {
    name      = local.active_profile.name
    url       = local.active_profile.url
    audiences = [var.zot_audience]
  }

  cel_validations = local.active_profile.zot_cel

  claim_mapping = {
    username = "repository"
    groups   = "repository_owner"
  }

  zot_rbac_policies = {
    "**" = {
      policies = [
        {
          groups  = [var.org_name]
          actions = ["read", "create", "update"]
        }
      ]
    }
  }
}
