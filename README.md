# terraform-aws-sns-notification-framework

This module creates a number of SNS topics and Slack Notification modules to provide a consistent alerting framework across multiple AWS accounts.  The focus is to be prescriptive about what types of SNS buckets are useful to our AWS projects, but you might find value in it, too.

## Features

* 4 Levels of notification: red, yellow, green, and security
* Slack notification, defaults to share a channel for all alerts, but allows overriding

## Usage

### Variables

#### Required

* `slack_webhook_key` - The key for your Slack webhook. This is the part of the webhook url after '/services/'.  Consider this a 'secret'.  As such, it is STRONGLY advised not to commit this into the repository, but instead use a ParameterStore data resource to retrieve the data.  Similarly, do not commit the terraform state files, but store them in an encrypted bucket.
* `slack_channel_default` - Default channel where messages should be sent

### Example

```terraform
# Looks up a ParameterStore value for the slack_webhook_key
# ex: data.aws_ssm_parameter.sns_topic_slack_webhook.value = T12341234/B12341234/H12345678901234567890
data "aws_ssm_parameter" "sns_topic_slack_webhook" {
  name = "/slack/webhooks/sns_notifications"
}

module "sns" {
  source  = "USSBA/sns-notification-framework/aws"
  version = "~> 2.0"

  name_prefix       = "my-sns"
  slack_webhook_key = data.aws_ssm_parameter.sns_topic_slack_webhook.value

  # Green and Yellow alerts will go to my-app-notifications, red is sent to -red, security is sent to security-alerts channel
  slack_channel_default           = "my-app-notifications"
  slack_channel_red_override      = "my-app-notifications-red"
  slack_channel_security_override = "security-alerts"
}
```

## Contributing

We welcome contributions. Please read [CONTRIBUTING.md](./CONTRIBUTING.md) for how to contribute.

We strive for a welcoming and inclusive environment for terraform-aws-sns-notification-framework.
Please follow this guidelines in all interactions:

1. Be Respectful: use welcoming and inclusive language.
2. Assume best intentions: seek to understand other's opinions.

### Terraform 0.12

Our code base now exists in Terraform 0.13 and we are halting new features in the Terraform 0.12 major version.  If you wish to make a PR or merge upstream changes back into 0.12, please submit a PR to the `terraform-0.12` branch.

## License

terraform-aws-sns-notification-framework is licensed under the Creative Commons Zero license
[A copy of that license](./LICENSE.md) is distributed with this software.

## Security Policy

Please do not submit an issue on GitHub for a security vulnerability.
Please contact the SBA at [{{ digital@sba.gov }}](mailto:{{ digital@sba.gov }}).

Be sure to include all the pertinent information.

## Maintainers

Created in 1953, the U.S. Small Business Administration (SBA) continues to help small business owners and entrepreneurs pursue the American dream. The SBA is the only cabinet-level federal agency fully dedicated to small business and provides counseling, capital, and contracting expertise as the nation’s only go-to resource and voice for small businesses.

By making source code available for sharing and re-use across Federal agencies, we can avoid duplicative custom software purchases and promote innovation and collaboration across Federal agencies. By opening more of our code to the brightest minds inside and outside of government, we can enable them to work together to ensure that the code is reliable and effective in furthering our national objectives. And we can do all of this while remaining consistent with the Federal Government’s long-standing policy of technology neutrality, through which we seek to ensure that Federal investments in IT are merit-based, improve the performance of our government, and create value for the American people.
