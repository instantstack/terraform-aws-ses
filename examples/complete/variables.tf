variable "dedicated_ip_pools" {
  type = any
  default = [
    {
      name         = "pool1"
      scaling_mode = "MANAGED"
    },
    {
      name         = "pool2"
      scaling_mode = "STANDARD"
    }
  ]
}

variable "configuration_sets" {
  type = any
  default = {
    config_set_1 = {
      name = "config-set-1"
      tracking_options = {
        custom_redirect_domain = "dev.example.com"
      }
      sending_options = {
        sending_enabled = true
      }
      reputation_options = {
        reputation_metrics_enabled = true
      }
      delivery_options = {
        sending_pool_name = "pool1"
        tls_policy        = "REQUIRE"
      }
      event_destinations = [
        {
          name                 = "example-sns-destination"
          service              = "sns"
          enabled              = true
          matching_event_types = ["SEND", "REJECT", "BOUNCE", "COMPLAINT"]
          service_options = {
            topic_arn = "arn:aws:sns:us-east-2:123456789012:my-cfg-set-destination"
          }
        },
        {
          name                 = "example-kinesis-destination"
          service              = "kinesis"
          enabled              = true
          matching_event_types = ["SEND", "REJECT", "BOUNCE", "COMPLAINT"]
          service_options = {
            stream_arn = "arn:aws:kinesis:us-east-2:123456789012:stream/example-stream"
          }
        }
      ]
    }
    config_set_2 = {
      name = "config-set-2"
      delivery_options = {
        tls_policy        = "OPTIONAL"
        sending_pool_name = "pool2"
      }
    }
  }
}