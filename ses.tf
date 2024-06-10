locals {
  custom_from_subdomain_enabled = length(var.custom_from_subdomain) > 0
}

resource "aws_ses_domain_identity" "ses_domain" {
  count = var.create ? 1 : 0

  domain = var.domain
}

resource "aws_route53_record" "amazonses_verification_record" {
  count = var.create && var.verify_domain ? 1 : 0

  zone_id = var.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "1800"
  records = [join("", aws_ses_domain_identity.ses_domain[*].verification_token)]
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  count = var.create ? 1 : 0

  domain = join("", aws_ses_domain_identity.ses_domain[*].domain)
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count = var.create && var.verify_dkim ? 3 : 0

  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim[0].dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "1800"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim[0].dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "amazonses_spf_record" {
  count = var.create && var.create_spf_record ? 1 : 0

  zone_id = var.zone_id
  name    = length(var.custom_from_subdomain) > 0 ? join("", aws_ses_domain_mail_from.custom_mail_from[*].mail_from_domain) : join("", aws_ses_domain_identity.ses_domain[*].domain)
  type    = "TXT"
  ttl     = "3600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_ses_domain_mail_from" "custom_mail_from" {
  count                  = local.custom_from_subdomain_enabled ? 1 : 0
  domain                 = join("", aws_ses_domain_identity.ses_domain[*].domain)
  mail_from_domain       = "${one(var.custom_from_subdomain)}.${join("", aws_ses_domain_identity.ses_domain[*].domain)}"
  behavior_on_mx_failure = var.custom_from_behavior_on_mx_failure
}

resource "aws_route53_record" "custom_mail_from_mx" {
  count = local.custom_from_subdomain_enabled ? 1 : 0

  zone_id = var.zone_id
  name    = join("", aws_ses_domain_mail_from.custom_mail_from[*].mail_from_domain)
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${join("", data.aws_region.current[*].name)}.amazonses.com"]
}
