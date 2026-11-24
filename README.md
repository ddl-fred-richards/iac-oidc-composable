# Composable OIDC Workload Identity & EMU Reference Architecture

Provider-agnostic OpenTofu / Terraform modules and portable CI workflows for zero-secret OIDC authentication across **AWS**, **Microsoft Entra ID**, **Auth0**, **JFrog Artifactory**, and **Zot Registry**, plus optional **GitHub EMU** SSO scaffolding.

Designed so swapping **GitHub** for **Forgejo** (or running both side-by-side) is a branch-level `.tfvars` change rather than a rewrite.

## Repository Layout

```text
iac-oidc-composable/
├── Taskfile.yml                       # Orchestrates tofu/terraform per profile + local Zot validation
├── .github/
│   ├── actions/get-oidc-jwt/          # Zero-dependency composite action (works on GitHub & Forgejo)
│   └── workflows/
│       ├── deploy-and-publish.yml     # 5-target OIDC showcase (AWS, Entra, Zot, JFrog, Auth0)
│       └── iac-split-plan-apply.yml   # Split read-only Plan / gated Apply OpenTofu pipeline
├── .forgejo/workflows/                # Symlink target for Forgejo Actions compatibility
├── modules/
│   ├── github-oidc-config/            # GitHub Org OIDC sub-claim customization (GitHub-only)
│   ├── emu-entra-sso/                 # Entra ID Enterprise App + SCIM for GitHub EMU (GitHub-only)
│   ├── idp-aws-oidc/                  # Provider-agnostic AWS IAM OIDC Provider + Role
│   ├── idp-entra-oidc/                # Provider-agnostic Azure UAMI + Federated Identity Credentials
│   ├── idp-auth0-oidc/                # Provider-agnostic Auth0 Custom Token Exchange (RFC 8693)
│   ├── reg-jfrog-oidc/                # Provider-agnostic JFrog OIDC Provider + Identity Mappings
│   └── reg-zot-oidc/                  # Provider-agnostic Zot config.json (auth.bearer.oidc + CEL)
└── stacks/
    ├── 00-foundation-emu/             # State 1: One-time EMU SSO bootstrap (prevent_destroy)
    └── 01-oidc-consumer/              # State 2: Composable IdP & registry consumers
```

## Quick Start

1. **Initialize Git & local `.tfvars` files:**
   ```bash
   cd iac-oidc-composable
   git init
   task bootstrap
   ```
2. **Edit your profile variables** (`stacks/01-oidc-consumer/github.tfvars` or `forgejo.tfvars`) and toggle which modules you want enabled (`enable_aws`, `enable_entra`, `enable_auth0`, `enable_jfrog`, `enable_zot`).
3. **Plan & Apply with OpenTofu (default) or Terraform:**
   ```bash
   # GitHub profile with OpenTofu
   task init
   task plan PROFILE=github

   # Forgejo profile (e.g. on a feat/forgejo branch)
   task plan PROFILE=forgejo

   # Override binary to Terraform if preferred
   task plan PROFILE=github IAC_BIN=terraform
   ```
4. **Validate rendered Zot `config.json` locally:**
   ```bash
   task zot:verify
   ```
5. **Link workflows for Forgejo:**
   ```bash
   task forgejo:link
   ```

## Branch-Swap Pattern (GitHub <-> Forgejo)

* **`main` branch:** Uses `PROFILE=github`. Enables `github-oidc-config` (custom `repo_property_*` claims) and sets JFrog `provider_type = "GitHub"`.
* **`feat/forgejo` branch:** Uses `PROFILE=forgejo`. Automatically disables GitHub-only modules (`github-oidc-config`, `emu-entra-sso`), switches JFrog to `provider_type = "generic"`, and updates issuer/JWKS URLs to your Forgejo instance.
