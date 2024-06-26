output "ses_domain_identity_arn" {
  value       = try(aws_ses_domain_identity.ses_domain[0].arn, "")
  description = "The ARN of the SES domain identity"
}

output "ses_domain_identity_verification_token" {
  value       = try(aws_ses_domain_identity.ses_domain[0].verification_token, "")
  description = "A code which when added to the domain as a TXT record will signal to SES that the owner of the domain has authorised SES to act on their behalf. The domain identity will be in state 'verification pending' until this is done. See below for an example of how this might be achieved when the domain is hosted in Route 53 and managed by Terraform. Find out more about verifying domains in Amazon SES in the AWS SES docs."
}

output "ses_dkim_tokens" {
  value       = try(aws_ses_domain_dkim.ses_domain_dkim.0.dkim_tokens, "")
  description = "A list of DKIM Tokens which, when added to the DNS Domain as CNAME records, allows for receivers to verify that emails were indeed authorized by the domain owner."
}

output "spf_record" {
  value       = try(aws_route53_record.amazonses_spf_record[0].fqdn, "")
  description = "The SPF record for the domain. This is a TXT record that should be added to the domain's DNS settings to allow SES to send emails on behalf of the domain."
}

output "custom_from_domain" {
  value       = try(join("", aws_ses_domain_mail_from.custom_mail_from[*].mail_from_domain))
  description = "The custom mail FROM domain"
}

output "user_name" {
  value       = try(aws_iam_group.ses_users[0].name, "")
  description = "Normalized IAM user name."
}

output "user_arn" {
  value       = try(aws_iam_group.ses_users[0].arn, "")
  description = "The ARN assigned by AWS for this user."
}

output "ses_group_name" {
  value       = local.ses_group_name
  description = "The IAM group name"
}

output "secret_access_key" {
  sensitive   = true
  value       = try(aws_iam_access_key.default[0].secret, "")
  description = "The IAM secret for usage with SES API. This will be written to the state file in plain text."
}

# https://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-credentials.html
output "ses_smtp_password" {
  sensitive   = true
  value       = try(aws_iam_access_key.default[0].ses_smtp_password_v4, "")
  description = "The SMTP password. This will be written to the state file in plain text."
}

output "access_key_id" {
  value       = try(aws_iam_access_key.default[0].id, "")
  description = "The SMTP user which is access key ID."
}
