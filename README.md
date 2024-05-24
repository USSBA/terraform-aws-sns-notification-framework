# terraform-aws-sns-notification-framework

## Description

This module will provision 4 unique SNS topics and for the moment let us refer to them as `Green`, `Yellow`, `Red`, and `Security`. A Lambda Function will also be provisioned and subscribed to each of the 4 topics to handle the notifications and relay them to the appropriate Microsoft Teams Webhook. If configured this module will use SES to relay Red and Security notification respectively.

### Topic Delegation

**Green** - This topic is for general purpose information.

  * Automated build has started
  * Automated build has completed
  * Backup Job started
  * Backup Job complete
  * Alarm transition to OK state

**Yellow** - This topic is for warning/precursor information.

  * CPU or Memory lower threshold is breaching
  * CI/CD build failure
  * Auto-Scaling Events
  * Low EBS or RDS diskspace

**Red** - This topic is used for critical application and infrastructure information.

  * CPU or Memory upper threshold is breaching
  * CI/CD deployment failure
  * Healthcheck failures

**Security** - This topic is used for CISO/SOC related information.

  * CVE has been detected
  * Unauthorized access has been detected
  * Credential reports
  * Out-of-date Package has been detected

## Usage

### Module Inputs

| Variable                      | Description                                                             |
| :-                            | :-                                                                      |
| *email_from*                  | **Optional;** Email address of the sender.                              |
| *email_to*                    | **Optional;** Email address of the reciever.                            |
| *encrypted*                   | **Optional;** Topics will be encrypted at rest using a KMS managed key. |
| *kms_key_alias*               | **Optional;** Required when _encrypted_ is turned on.                   |
| *log_group_retention_in_days* | **Optional;** Number of days applied to the log group retention policy. |
| *name_prefix*                 | **Required;** Unique name prefix used to label resources.               |
| *webhook_url_green*           | **Required;** MS Teams WebHook URI for Green Alerts.                    |
| *webhook_url_red*             | **Required;** MS Teams WebHook URL for Red Alerts.                      |
| *webhook_url_security*        | **Required;** MS Teams WebHook URL for Security Alerts.                 |
| *webhook_url_yellow*          | **Required;** MS Teams WebHook URL for Yellow Alerts.                   |

> <br/>**Considering Email Alerts?** <br/><br/>
> Please note that if you choose to configure the `email_from` and `email_to` that you may be subject to additional SES configuration. For instance both addresses will need to be verified or at the very least the senders domain. You may also need to place a service request with AWS to lift SES out of its default `sandbox` configuration.<br/><br/>

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
