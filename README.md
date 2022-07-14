# terraform-aws-sns-notification-framework

This module creates a number of SNS topics and Slack Notification modules to provide a consistent alerting framework across multiple AWS accounts.  The focus is to be prescriptive about what types of SNS buckets are useful to our AWS projects, but you might find value in it, too.

## Features

* 4 Levels of notification: red, yellow, green, and security
* Slack notification, defaults to share a channel for all alerts, but allows overriding

## Usage

### Variables

#### Required for Teams notifications

* `default_teams_webhook_url` - The URL for your Teams webhook. This includes `https://`.  Consider this a 'secret'.  As such, it is STRONGLY advised not to commit this into the repository, but instead use a ParameterStore data resource to retrieve the data.  Similarly, do not commit the terraform state files, but store them in an encrypted bucket.

#### Optional

* `green_overrides`, `yellow_overrides`, `red_overrides`, `security_overrides` - Maps to configure any color-specific values.
  * Map elements are named by removing `default_` from the other module variables.
  * `{teams_webhook_url = ""}`
* `cloudwatch_log_group_retention_in_days` - How long to retain cloudwatch logs for lambda.  Defaults to `0`, forever.

### Example

See [examples directory](./examples)

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
