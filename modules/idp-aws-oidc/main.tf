data "tls_certificate" "oidc" {
  url = var.oidc_issuer.url
}

resource "aws_iam_openid_connect_provider" "this" {
  url             = var.oidc_issuer.url
  client_id_list  = var.oidc_issuer.audiences
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
}

locals {
  issuer_host = replace(var.oidc_issuer.url, "https://", "")
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.issuer_host}:aud"
      values   = var.oidc_issuer.audiences
    }

    condition {
      test     = "StringLike"
      variable = "${local.issuer_host}:${var.oidc_issuer.subject_claim}"
      values   = var.allowed_subjects
    }

    dynamic "condition" {
      for_each = var.extra_claim_conditions
      content {
        test     = "StringEquals"
        variable = "${local.issuer_host}:${condition.key}"
        values   = condition.value
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
