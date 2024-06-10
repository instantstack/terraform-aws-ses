locals {
  create_group_enabled = var.create && var.ses_group_enabled
  create_user_enabled  = var.create && var.ses_user_enabled
  
  username             = local.create_user_enabled ? coalesce(var.ses_user_name, "ses-user-${random_id.id.0.hex}") : null
  access_key           = local.create_user_enabled ? aws_iam_access_key.default : null
  ses_group_name       = local.create_group_enabled ? var.ses_group_name : null
}

resource "random_id" "id" {
  count = local.create_user_enabled ? 1 : 0

  byte_length = 6
}

resource "aws_iam_group" "ses_users" {
  count = local.create_group_enabled ? 1 : 0

  name = local.ses_group_name
  path = var.ses_group_path
}

resource "aws_iam_group_policy" "ses_group_policy" {
  count = local.create_group_enabled ? 1 : 0

  name  = var.ses_group_name
  group = aws_iam_group.ses_users[0].name

  policy = join("", data.aws_iam_policy_document.ses_policy[*].json)
}

resource "aws_iam_user_group_membership" "ses_user" {
  count = local.create_group_enabled && local.create_user_enabled ? 1 : 0

  user = local.username

  groups = [
    aws_iam_group.ses_users[0].name
  ]
}

resource "aws_iam_user" "default" {
  count         = local.create_user_enabled ? 1 : 0
  name          = local.username
  path          = "/"
  force_destroy = var.ses_user_force_destroy
  tags          = var.tags
}

resource "aws_iam_access_key" "default" {
  count = local.create_user_enabled ? 1 : 0
  user  = local.username

  depends_on = [ aws_iam_user.default ]
}

resource "aws_iam_user_policy" "sending_emails" {
  count = local.create_user_enabled && !local.create_group_enabled ? 1 : 0

  name   = "SendingEmailsPolicy-${random_id.id.0.hex}"
  policy = join("", data.aws_iam_policy_document.ses_policy[*].json)
  user   = local.username
}