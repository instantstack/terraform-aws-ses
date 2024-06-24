variable "create" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "create_domain_identity" {
  description = "Set to false to prevent the module from creating a domain identity"
  type        = bool
  default     = true
}

variable "domain" {
  description = "The domain to create the SES identity for."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "zone_id" {
  type        = string
  description = "Route53 parent zone ID. If provided (not empty), the module will create Route53 DNS records used for verification"
  default     = ""
}

variable "verify_domain" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for domain verification."
  default     = false
}

variable "verify_dkim" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for DKIM verification."
  default     = false
}

variable "create_spf_record" {
  type        = bool
  description = "If provided the module will create an SPF record for `domain`."
  default     = false
}

variable "custom_from_subdomain" {
  type        = list(string)
  description = "If provided the module will create a custom subdomain for the `From` address."
  default     = []
  nullable    = false

  validation {
    condition     = length(var.custom_from_subdomain) <= 1
    error_message = "Only one custom_from_subdomain is allowed."
  }

  validation {
    condition     = length(var.custom_from_subdomain) > 0 ? can(regex("^[a-zA-Z0-9-]+$", var.custom_from_subdomain[0])) : true
    error_message = "The custom_from_subdomain must be a valid subdomain."
  }
}

variable "custom_from_behavior_on_mx_failure" {
  type        = string
  description = "The behaviour of the custom_from_subdomain when the MX record is not found. Defaults to `UseDefaultValue`."
  default     = "UseDefaultValue"

  validation {
    condition     = contains(["UseDefaultValue", "RejectMessage"], var.custom_from_behavior_on_mx_failure)
    error_message = "The custom_from_behavior_on_mx_failure must be `UseDefaultValue` or `RejectMessage`."
  }
}

variable "iam_permissions" {
  type        = list(string)
  description = "Specifies permissions for the IAM user."
  default     = ["ses:SendRawEmail"]
}

variable "iam_allowed_resources" {
  type        = list(string)
  description = "Specifies resource ARNs that are enabled for `var.iam_permissions`. Wildcards are acceptable."
  default     = []
}

variable "ses_group_enabled" {
  type        = bool
  description = "Creates a group with permission to send emails from SES domain"
  default     = false
}

variable "ses_group_name" {
  type        = string
  description = "The name of the IAM group to create."
  default     = ""
}

variable "ses_group_path" {
  type        = string
  description = "The IAM Path of the group to create"
  default     = "/"
}

variable "ses_user_enabled" {
  type        = bool
  description = "Creates user with permission to send emails from SES domain"
  default     = true
}

variable "ses_user_name" {
  description = "The name of the SES user to create."
  type        = string
  default     = ""
}

variable "ses_user_force_destroy" {
  description = "When true, forces the destruction of the SES user."
  type        = bool
  default     = false
}

variable "dedicated_ip_pools" {
  description = "List of dedicated IP pools to create."
  type = list(object({
    name         = string
    scaling_mode = string
  }))
  default = []
}

variable "configuration_sets" {
  type = map(object({
    name = string
    delivery_options = optional(object({
      sending_pool_name = optional(string)
      tls_policy        = optional(string)
    }), {})
    reputation_options = optional(object({
      reputation_metrics_enabled = optional(bool)
    }), {})
    sending_options = optional(object({
      sending_enabled = optional(bool)
    }), {})
    suppression_options = optional(object({
      suppressed_email_addresses = optional(list(string))
    }), {})
    tracking_options = optional(object({
      custom_redirect_domain = optional(string)
    }), {})
    event_destinations = optional(list(object(
      {
        name                 = string
        service              = optional(string)
        enabled              = optional(bool)
        matching_event_types = optional(list(string))
        service_options = optional(object(
          {
            default_dimension_value  = optional(string, null)
            dimension_name           = optional(string, null)
            dimension_value_source   = optional(string, null)
            topic_arn                = optional(string, null)
            delivery_stream_arn      = optional(string, null)
            iam_role_arn             = optional(string, null)
            pinpoint_application_arn = optional(string, null)
          }
        ))
      }
    )), [])
    tags = optional(map(string))
  }))
  description = "List of SES configuration sets to create. In service_options you can specify only the needed fields related to the service. To see more: https://registry.terraform.io/providers/hashicorp/aws/5.54.1/docs/resources/sesv2_configuration_set"
  default     = {}
}