# terraform-aws-sns-notification-framework

This module creates a number of SNS topics and Slack Notification modules to provide a consistent alerting framework across multiple AWS accounts.

## Usage

### Variables

#### Required
* `slack_webhook_key` - The key for your Slack webhook. This is the part of the webhook url after '/services/'.  Consider this a 'secret'.  As such, it is STRONGLY advised not to commit this into the repository, but instead use a ParameterStore data resource to retrieve the data.  Similarly, do not commit the terraform state files, but store them in an encrypted bucket.
* `slack_channel_default` - Default channel where messages should be sent

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
A copy of that license is distributed with this software.

## Security Policy

Please do not submit an issue on GitHub for a security vulnerability.
Please contact the SBA at [{{ digital@sba.gov }}](mailto:{{ digital@sba.gov }}).

Be sure to include all the pertinent information.

## Maintainers

Created in 1953, the U.S. Small Business Administration (SBA) continues to help small business owners and entrepreneurs pursue the American dream. The SBA is the only cabinet-level federal agency fully dedicated to small business and provides counseling, capital, and contracting expertise as the nation’s only go-to resource and voice for small businesses.

By making source code available for sharing and re-use across Federal agencies, we can avoid duplicative custom software purchases and promote innovation and collaboration across Federal agencies. By opening more of our code to the brightest minds inside and outside of government, we can enable them to work together to ensure that the code is reliable and effective in furthering our national objectives. And we can do all of this while remaining consistent with the Federal Government’s long-standing policy of technology neutrality, through which we seek to ensure that Federal investments in IT are merit-based, improve the performance of our government, and create value for the American people.

