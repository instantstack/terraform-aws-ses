module "complete" {
  source = "../.."

  create                             = true
  create_domain_identity             = true
  domain                             = "dev.example.com"
  zone_id                            = "Z1234567890ABCDEF123456"
  custom_from_behavior_on_mx_failure = "UseDefaultValue"
  custom_from_subdomain              = []
  verify_domain                      = true
  verify_dkim                        = true
  create_spf_record                  = true
  ses_user_enabled                   = true
  ses_user_name                      = "ses-user"
  ses_group_enabled                  = true
  ses_group_name                     = "ses-users"
  ses_group_path                     = "/"
  iam_permissions                    = ["ses:SendRawEmail", "ses:SendEmail"]
  iam_allowed_resources              = ["*"]
  dedicated_ip_pools                 = var.dedicated_ip_pools
  configuration_sets                 = var.configuration_sets

  tags = {
    Environment = "test"
  }
}