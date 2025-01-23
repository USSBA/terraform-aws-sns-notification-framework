# terraform-aws-sns-notification-framework

## Description

This module will send an email to a recipient or a list of recipients when a Cloudwatch Alarm changes state. It will provision an SNS topic and Lambda Function for SNS alerts. A Lambda Function will be provisioned and subscribed to the SNS topic to handle the alarm notifications and relay them to the appropriate list of email recipients. If configured, this module will use SES to notify email recipients.

### Topic Delegation

A single topic is used for general purpose information, warnings, critical application and infrastructure information.

#### Supported AWS Services

At present, the only supported service is Cloudwatch Alarms, but in the future, we intend to expand to other types of services such as AWS Backup Vault.

#### Email

The Cloudwatch Alarm title and description will be in the email subject and body. The alarm state, event time and a link to the alarm will be provided in the email. Metric details will show information about the MetricName, Threshold and Namespace for the alarm.

## Usage

### Module Inputs

| Variable                      | Description                                                             |
| :-                            | :-                                                                      |
| *email_from*                  | **Optional;** Email address of the sender.                              |
| *email_to*                    | **Optional;** Email address or a list of recipients.                    |
| *encrypted*                   | **Optional;** Topics will be encrypted at rest using a KMS managed key. |
| *kms_key_alias*               | **Optional;** Required when _encrypted_ is turned on.                   |
| *log_group_retention_in_days* | **Optional;** Number of days applied to the log group retention policy. |
| *name_prefix*                 | **Required;** Unique name prefix used to label resources.               |

> <br/>**Considering Email Alerts?** <br/><br/>
> Please note that if you choose to configure the `email_from` and `email_to` that you may be subject to additional SES configuration. For instance both addresses (and list of addresses if more than one) will need to be verified or at the very least the senders domain. You may also need to place a service request with AWS to lift SES out of its default `sandbox` configuration.<br/><br/>


## Contributing

We welcome contributions. Please read [CONTRIBUTING.md](./CONTRIBUTING.md) for how to contribute.

We strive for a welcoming and inclusive environment for terraform-aws-sns-notification-framework.
Please follow this guidelines in all interactions:

1. Be Respectful: use welcoming and inclusive language.
2. Assume best intentions: seek to understand other's opinions.

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
