# terraform-aws-sns-notification-framework

## Description

This module requires the use of AWS Simple Email Service (SES) to send it's notifications.

## Support

The following list of AWS services are supported:
- CloudWatch Alarms

**Note:** We do plan to support other AWS services such as Backup Vault in the future.

## Usage

**Important**
- If your SES is currently in sandbox then all email identities must be verified.
- If your SES is no longer in sandbox then only the sender's email address or the sender's domain must be verified identities.

After deploying this module to the AWS account the SRE will need to create or adjust their CloudWatch Alarm configuration. The Alarm's `alarm_action` and/or `ok_action` should point at the SNS topic provisioned by this module.

### Module Inputs

| Variable                      | Description                                                                           |
| :-                            | :-                                                                                    |
| *email_from*                  | **Required;** The designated email address used as the sender of email notifications. |
| *email_to*                    | **Required;** The designated list of recipient email address of email notifications.  |
| *encrypted*                   | **Optional;** Topics will be encrypted at rest using a KMS managed key.               |
| *kms_key_alias*               | **Optional;** Required when _encrypted_ is turned on.                                 |
| *log_group_retention_in_days* | **Optional;** Number of days applied to the log group retention policy.               |
| *name_prefix*                 | **Required;** Unique name prefix used to label resources.                             |

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
