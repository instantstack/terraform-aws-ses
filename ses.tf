# domain configuration 
locals {
  custom_from_subdomain_enabled = length(var.custom_from_subdomain) > 0
}

resource "aws_ses_domain_identity" "ses_domain" {
  count = var.create && var.create_domain_identity ? 1 : 0

  domain = var.domain
}

resource "aws_route53_record" "amazonses_verification_record" {
  count = var.create && var.create_domain_identity && var.verify_domain ? 1 : 0

  zone_id = var.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "1800"
  records = [join("", aws_ses_domain_identity.ses_domain[*].verification_token)]
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  count = var.create && var.create_domain_identity ? 1 : 0

  domain = join("", aws_ses_domain_identity.ses_domain[*].domain)
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count = var.create && var.create_domain_identity && var.verify_dkim ? 3 : 0

  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim[0].dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "1800"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim[0].dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "amazonses_spf_record" {
  count = var.create && var.create_domain_identity && var.create_spf_record ? 1 : 0

  zone_id = var.zone_id
  name    = length(var.custom_from_subdomain) > 0 ? join("", aws_ses_domain_mail_from.custom_mail_from[*].mail_from_domain) : join("", aws_ses_domain_identity.ses_domain[*].domain)
  type    = "TXT"
  ttl     = "3600"
  records = ["v=spf1 include:amazonses.com -all"]
}

resource "aws_ses_domain_mail_from" "custom_mail_from" {
  count                  = var.create && local.custom_from_subdomain_enabled ? 1 : 0
  domain                 = join("", aws_ses_domain_identity.ses_domain[*].domain)
  mail_from_domain       = "${one(var.custom_from_subdomain)}.${join("", aws_ses_domain_identity.ses_domain[*].domain)}"
  behavior_on_mx_failure = var.custom_from_behavior_on_mx_failure
}

resource "aws_route53_record" "custom_mail_from_mx" {
  count = var.create && local.custom_from_subdomain_enabled ? 1 : 0

  zone_id = var.zone_id
  name    = join("", aws_ses_domain_mail_from.custom_mail_from[*].mail_from_domain)
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${join("", data.aws_region.current[*].name)}.amazonses.com"]
}

resource "aws_sesv2_dedicated_ip_pool" "pools" {
  count        = var.create ? length(var.dedicated_ip_pools) : 0
  pool_name    = var.dedicated_ip_pools[count.index].name
  scaling_mode = var.dedicated_ip_pools[count.index].scaling_mode

  tags = var.tags
}

# Configuration sets
locals {
  configuration_sets_with_tracking_options = {
    for set in var.configuration_sets : set.name => set
    if lookup(set.tracking_options, "custom_redirect_domain", null) != null
  }
  configuration_sets_without_tracking_options = {
    for set in var.configuration_sets : set.name => set
    if lookup(set.tracking_options, "custom_redirect_domain", null) == null
  }
}

resource "aws_sesv2_configuration_set" "configs_with_tracking_options" {
  for_each = local.configuration_sets_with_tracking_options

  configuration_set_name = each.value.name

  dynamic "delivery_options" {
    for_each = try(each.value.delivery_options, {}) != {} ? { delivery_options = each.value.delivery_options } : {}

    content {
      sending_pool_name = lookup(delivery_options.value, "sending_pool_name", null)
      tls_policy        = lookup(delivery_options.value, "tls_policy", null)
    }
  }

  dynamic "reputation_options" {
    for_each = try(each.value.reputation_options, {}) != {} ? { reputation_options = each.value.reputation_options } : {}

    content {
      reputation_metrics_enabled = lookup(reputation_options.value, "reputation_metrics_enabled", null)
    }
  }

  dynamic "sending_options" {
    for_each = try(each.value.sending_options, {}) != {} ? { sending_options = each.value.sending_options } : {}

    content {
      sending_enabled = lookup(sending_options.value, "sending_enabled", null)
    }
  }

  dynamic "suppression_options" {
    for_each = try(each.value.suppression_options, {}) != {} ? { suppression_options = each.value.suppression_options } : {}

    content {
      suppressed_reasons = lookup(suppression_options.value, "suppressed_reasons", null)
    }
  }

  tracking_options {
    custom_redirect_domain = each.value.tracking_options.custom_redirect_domain
  }
}

resource "aws_sesv2_configuration_set" "configs_without_tracking_options" {
  for_each = local.configuration_sets_without_tracking_options

  configuration_set_name = each.value.name

  dynamic "delivery_options" {
    for_each = try(each.value.delivery_options, {}) != {} ? { delivery_options = each.value.delivery_options } : {}

    content {
      sending_pool_name = lookup(each.value, "sending_pool_name", null)
      tls_policy        = lookup(each.value, "tls_policy", null)
    }
  }

  dynamic "reputation_options" {
    for_each = try(each.value.reputation_options, {}) != {} ? { reputation_options = each.value.reputation_options } : {}

    content {
      reputation_metrics_enabled = lookup(reputation_options.value, "reputation_metrics_enabled", null)
    }
  }

  dynamic "sending_options" {
    for_each = try(each.value.sending_options, {}) != {} ? { sending_options = each.value.sending_options } : {}

    content {
      sending_enabled = lookup(sending_options.value, "sending_enabled", null)
    }
  }

  dynamic "suppression_options" {
    for_each = try(each.value.suppression_options, {}) != {} ? { suppression_options = each.value.suppression_options } : {}

    content {
      suppressed_reasons = lookup(suppression_options.value, "suppressed_reasons", null)
    }
  }
}

locals {
  all_event_destination_configuration_sets = flatten([
    for set in var.configuration_sets : [
      for dest in set.event_destinations : merge(dest, { configuration_set_name = set.name })
    ]
  ])

  cloudwatch_event_destination_configuration_sets = [
    for destination in local.all_event_destination_configuration_sets : destination
    if destination.service == "cloudwatch"
  ]

  sns_event_destination_configuration_sets = [
    for destination in local.all_event_destination_configuration_sets : destination
    if destination.service == "sns"
  ]

  firehose_event_destination_configuration_sets = [
    for destination in local.all_event_destination_configuration_sets : destination
    if destination.service == "firehose"
  ]

  pinpoint_event_destination_configuration_sets = [
    for destination in local.all_event_destination_configuration_sets : destination
    if destination.service == "pinpoint"
  ]
}

resource "aws_sesv2_configuration_set_event_destination" "cloudwatch" {
  count                  = length(local.cloudwatch_event_destination_configuration_sets)
  configuration_set_name = local.cloudwatch_event_destination_configuration_sets[count.index].configuration_set_name
  event_destination_name = local.cloudwatch_event_destination_configuration_sets[count.index].name

  event_destination {
    cloud_watch_destination {
      dimension_configuration {
        default_dimension_value = local.cloudwatch_event_destination_configuration_sets[count.index].service_options.default_dimension_value
        dimension_name          = local.cloudwatch_event_destination_configuration_sets[count.index].service_options.dimension_name
        dimension_value_source  = local.cloudwatch_event_destination_configuration_sets[count.index].service_options.dimension_value_source
      }
    }

    enabled              = local.cloudwatch_event_destination_configuration_sets[count.index].enabled
    matching_event_types = local.cloudwatch_event_destination_configuration_sets[count.index].matching_event_types
  }
}

resource "aws_sesv2_configuration_set_event_destination" "sns" {
  count                  = length(local.sns_event_destination_configuration_sets)
  configuration_set_name = local.sns_event_destination_configuration_sets[count.index].configuration_set_name
  event_destination_name = local.sns_event_destination_configuration_sets[count.index].name

  event_destination {
    sns_destination {
      topic_arn = local.sns_event_destination_configuration_sets[count.index].service_options.topic_arn
    }

    enabled              = local.sns_event_destination_configuration_sets[count.index].enabled
    matching_event_types = local.sns_event_destination_configuration_sets[count.index].matching_event_types
  }
}

resource "aws_sesv2_configuration_set_event_destination" "firehose" {
  count                  = length(local.firehose_event_destination_configuration_sets)
  configuration_set_name = local.firehose_event_destination_configuration_sets[count.index].configuration_set_name
  event_destination_name = local.firehose_event_destination_configuration_sets[count.index].name

  event_destination {
    kinesis_firehose_destination {
      delivery_stream_arn = local.firehose_event_destination_configuration_sets[count.index].service_options.delivery_stream_arn
      iam_role_arn        = local.firehose_event_destination_configuration_sets[count.index].service_options.iam_role_arn
    }

    enabled              = local.firehose_event_destination_configuration_sets[count.index].enabled
    matching_event_types = local.firehose_event_destination_configuration_sets[count.index].matching_event_types
  }
}

resource "aws_sesv2_configuration_set_event_destination" "pinpoint" {
  count                  = length(local.pinpoint_event_destination_configuration_sets)
  configuration_set_name = local.pinpoint_event_destination_configuration_sets[count.index].configuration_set_name
  event_destination_name = local.pinpoint_event_destination_configuration_sets[count.index].name

  event_destination {
    pinpoint_destination {
      application_arn = local.pinpoint_event_destination_configuration_sets[count.index].service_options.pinpoint_application_arn
    }

    enabled              = local.pinpoint_event_destination_configuration_sets[count.index].enabled
    matching_event_types = local.pinpoint_event_destination_configuration_sets[count.index].matching_event_types
  }
}