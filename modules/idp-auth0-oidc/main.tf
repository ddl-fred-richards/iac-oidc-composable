resource "auth0_action" "ci_oidc_exchange" {
  name    = "ci-oidc-exchange-${var.oidc_issuer.name}"
  runtime = "node22"
  deploy  = true

  supported_triggers {
    id      = "custom-token-exchange"
    version = "v1"
  }

  dependencies {
    name    = "jose"
    version = "5.9.6"
  }

  secrets {
    name  = "OIDC_ISSUER"
    value = var.oidc_issuer.url
  }
  secrets {
    name  = "OIDC_JWKS_URI"
    value = var.oidc_issuer.jwks_uri
  }
  secrets {
    name  = "OIDC_AUDIENCE"
    value = var.oidc_issuer.audience
  }
  secrets {
    name  = "ALLOWED_REPO_PREFIX"
    value = var.oidc_issuer.allowed_repo_pfx
  }
  secrets {
    name  = "ALLOWED_REF"
    value = var.oidc_issuer.allowed_ref
  }
  secrets {
    name  = "SERVICE_ACCOUNT_USER_ID"
    value = var.service_account_user_id
  }

  code = <<-EOT
    const { createRemoteJWKSet, jwtVerify } = require('jose');

    exports.onExecuteCustomTokenExchange = async (event, api) => {
      const token = event.transaction.subject_token;
      const JWKS = createRemoteJWKSet(new URL(event.secrets.OIDC_JWKS_URI));

      try {
        const { payload } = await jwtVerify(token, JWKS, {
          issuer: event.secrets.OIDC_ISSUER,
          audience: event.secrets.OIDC_AUDIENCE,
        });

        const repo = payload.repository || '';
        const ref  = payload.ref || '';

        if (!repo.startsWith(event.secrets.ALLOWED_REPO_PREFIX) || ref !== event.secrets.ALLOWED_REF) {
          return api.access.rejectInvalidSubjectToken(`Unauthorized repo/ref: $${repo} ($${ref})`);
        }

        api.authentication.setUserById(event.secrets.SERVICE_ACCOUNT_USER_ID);
      } catch (err) {
        return api.access.rejectInvalidSubjectToken(`JWT verification failed: $${err.message}`);
      }
    };
  EOT
}

resource "auth0_token_exchange_profile" "ci_oidc" {
  name               = "ci-oidc-${var.oidc_issuer.name}"
  subject_token_type = var.subject_token_type
  action_id          = auth0_action.ci_oidc_exchange.id
  type               = "custom_authentication"
}

resource "auth0_client" "ci_exchange_client" {
  name        = "ci-oidc-exchange-${var.oidc_issuer.name}"
  app_type    = "regular_web"
  grant_types = ["urn:ietf:params:oauth:grant-type:token-exchange"]

  token_exchange {
    allow_any_profile_of_type = ["custom_authentication"]
  }
}
