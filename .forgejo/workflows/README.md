# Forgejo Actions Workflows

Run `task forgejo:link` from the repository root to symlink `.github/workflows/*.yml` into this directory.
Because all workflows use the zero-dependency composite action `.github/actions/get-oidc-jwt` and standard CLIs, they run unchanged on Forgejo Actions runners.
