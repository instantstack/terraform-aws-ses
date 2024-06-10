data "aws_region" "current" {
  count = local.custom_from_subdomain_enabled ? 1 : 0
}

data "aws_iam_policy_document" "ses_policy" {
  count = local.create_user_enabled || local.create_group_enabled ? 1 : 0

  statement {
    actions   = var.iam_permissions
    resources = concat(aws_ses_domain_identity.ses_domain[*].arn, var.iam_allowed_resources)
  }
}

