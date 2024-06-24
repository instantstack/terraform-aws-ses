# terraform-aws-ses
Terraform module for Amazon SES identity and configuration sets

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_group.ses_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy.ses_group_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy) | resource |
| [aws_iam_user.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_group_membership.ses_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership) | resource |
| [aws_iam_user_policy.sending_emails](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_route53_record.amazonses_dkim_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.amazonses_spf_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.amazonses_verification_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.custom_mail_from_mx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ses_domain_dkim.ses_domain_dkim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim) | resource |
| [aws_ses_domain_identity.ses_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity) | resource |
| [aws_ses_domain_mail_from.custom_mail_from](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_mail_from) | resource |
| [aws_sesv2_configuration_set.configs_with_tracking_options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_configuration_set) | resource |
| [aws_sesv2_configuration_set.configs_without_tracking_options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_configuration_set) | resource |
| [aws_sesv2_configuration_set_event_destination.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_configuration_set_event_destination) | resource |
| [aws_sesv2_configuration_set_event_destination.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_configuration_set_event_destination) | resource |
| [aws_sesv2_configuration_set_event_destination.pinpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_configuration_set_event_destination) | resource |
| [aws_sesv2_configuration_set_event_destination.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_configuration_set_event_destination) | resource |
| [aws_sesv2_dedicated_ip_pool.pools](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_dedicated_ip_pool) | resource |
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_iam_policy_document.ses_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configuration_sets"></a> [configuration\_sets](#input\_configuration\_sets) | List of SES configuration sets to create. In service\_options you can specify only the needed fields related to the service. To see more: https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/resources/sesv2_configuration_set | <pre>map(object({<br>    name = string<br>    delivery_options = optional(object({<br>      sending_pool_name = optional(string)<br>      tls_policy        = optional(string)<br>    }), {})<br>    reputation_options = optional(object({<br>      reputation_metrics_enabled = optional(bool)<br>    }), {})<br>    sending_options = optional(object({<br>      sending_enabled = optional(bool)<br>    }), {})<br>    suppression_options = optional(object({<br>      suppressed_email_addresses = optional(list(string))<br>    }), {})<br>    tracking_options = optional(object({<br>      custom_redirect_domain = optional(string)<br>    }), {})<br>    event_destinations = optional(list(object(<br>      {<br>        name                 = string<br>        service              = optional(string)<br>        enabled              = optional(bool)<br>        matching_event_types = optional(list(string))<br>        service_options = optional(object(<br>          {<br>            default_dimension_value  = optional(string, null)<br>            dimension_name           = optional(string, null)<br>            dimension_value_source   = optional(string, null)<br>            topic_arn                = optional(string, null)<br>            delivery_stream_arn      = optional(string, null)<br>            iam_role_arn             = optional(string, null)<br>            pinpoint_application_arn = optional(string, null)<br>          }<br>        ))<br>      }<br>    )), [])<br>    tags = optional(map(string))<br>  }))</pre> | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Set to false to prevent the module from creating any resources | `bool` | `true` | no |
| <a name="input_create_domain_identity"></a> [create\_domain\_identity](#input\_create\_domain\_identity) | Set to false to prevent the module from creating a domain identity | `bool` | `true` | no |
| <a name="input_create_spf_record"></a> [create\_spf\_record](#input\_create\_spf\_record) | If provided the module will create an SPF record for `domain`. | `bool` | `false` | no |
| <a name="input_custom_from_behavior_on_mx_failure"></a> [custom\_from\_behavior\_on\_mx\_failure](#input\_custom\_from\_behavior\_on\_mx\_failure) | The behaviour of the custom\_from\_subdomain when the MX record is not found. Defaults to `UseDefaultValue`. | `string` | `"UseDefaultValue"` | no |
| <a name="input_custom_from_subdomain"></a> [custom\_from\_subdomain](#input\_custom\_from\_subdomain) | If provided the module will create a custom subdomain for the `From` address. | `list(string)` | `[]` | no |
| <a name="input_dedicated_ip_pools"></a> [dedicated\_ip\_pools](#input\_dedicated\_ip\_pools) | List of dedicated IP pools to create. | <pre>list(object({<br>    name         = string<br>    scaling_mode = string<br>  }))</pre> | `[]` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The domain to create the SES identity for. | `string` | `""` | no |
| <a name="input_iam_allowed_resources"></a> [iam\_allowed\_resources](#input\_iam\_allowed\_resources) | Specifies resource ARNs that are enabled for `var.iam_permissions`. Wildcards are acceptable. | `list(string)` | `[]` | no |
| <a name="input_iam_permissions"></a> [iam\_permissions](#input\_iam\_permissions) | Specifies permissions for the IAM user. | `list(string)` | <pre>[<br>  "ses:SendRawEmail"<br>]</pre> | no |
| <a name="input_ses_group_enabled"></a> [ses\_group\_enabled](#input\_ses\_group\_enabled) | Creates a group with permission to send emails from SES domain | `bool` | `false` | no |
| <a name="input_ses_group_name"></a> [ses\_group\_name](#input\_ses\_group\_name) | The name of the IAM group to create. | `string` | `""` | no |
| <a name="input_ses_group_path"></a> [ses\_group\_path](#input\_ses\_group\_path) | The IAM Path of the group to create | `string` | `"/"` | no |
| <a name="input_ses_user_enabled"></a> [ses\_user\_enabled](#input\_ses\_user\_enabled) | Creates user with permission to send emails from SES domain | `bool` | `true` | no |
| <a name="input_ses_user_force_destroy"></a> [ses\_user\_force\_destroy](#input\_ses\_user\_force\_destroy) | When true, forces the destruction of the SES user. | `bool` | `false` | no |
| <a name="input_ses_user_name"></a> [ses\_user\_name](#input\_ses\_user\_name) | The name of the SES user to create. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_verify_dkim"></a> [verify\_dkim](#input\_verify\_dkim) | If provided the module will create Route53 DNS records used for DKIM verification. | `bool` | `false` | no |
| <a name="input_verify_domain"></a> [verify\_domain](#input\_verify\_domain) | If provided the module will create Route53 DNS records used for domain verification. | `bool` | `false` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 parent zone ID. If provided (not empty), the module will create Route53 DNS records used for verification | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key_id"></a> [access\_key\_id](#output\_access\_key\_id) | The SMTP user which is access key ID. |
| <a name="output_custom_from_domain"></a> [custom\_from\_domain](#output\_custom\_from\_domain) | The custom mail FROM domain |
| <a name="output_secret_access_key"></a> [secret\_access\_key](#output\_secret\_access\_key) | The IAM secret for usage with SES API. This will be written to the state file in plain text. |
| <a name="output_ses_dkim_tokens"></a> [ses\_dkim\_tokens](#output\_ses\_dkim\_tokens) | A list of DKIM Tokens which, when added to the DNS Domain as CNAME records, allows for receivers to verify that emails were indeed authorized by the domain owner. |
| <a name="output_ses_domain_identity_arn"></a> [ses\_domain\_identity\_arn](#output\_ses\_domain\_identity\_arn) | The ARN of the SES domain identity |
| <a name="output_ses_domain_identity_verification_token"></a> [ses\_domain\_identity\_verification\_token](#output\_ses\_domain\_identity\_verification\_token) | A code which when added to the domain as a TXT record will signal to SES that the owner of the domain has authorised SES to act on their behalf. The domain identity will be in state 'verification pending' until this is done. See below for an example of how this might be achieved when the domain is hosted in Route 53 and managed by Terraform. Find out more about verifying domains in Amazon SES in the AWS SES docs. |
| <a name="output_ses_group_name"></a> [ses\_group\_name](#output\_ses\_group\_name) | The IAM group name |
| <a name="output_ses_smtp_password"></a> [ses\_smtp\_password](#output\_ses\_smtp\_password) | The SMTP password. This will be written to the state file in plain text. |
| <a name="output_spf_record"></a> [spf\_record](#output\_spf\_record) | The SPF record for the domain. This is a TXT record that should be added to the domain's DNS settings to allow SES to send emails on behalf of the domain. |
| <a name="output_user_arn"></a> [user\_arn](#output\_user\_arn) | The ARN assigned by AWS for this user. |
| <a name="output_user_name"></a> [user\_name](#output\_user\_name) | Normalized IAM user name. |

## Authors

Module managed by [Bruno Dias](https://github.com/brunordias) and [Ian Soares](https://github.com/Ian-Soares).

## License

Apache 2 Licensed. See LICENSE for full details.
