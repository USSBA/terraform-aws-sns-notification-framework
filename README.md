# terraform-aws-sns-notification-framework

This module creates a number of SNS topics and Slack Notification modules to provide a consistent alerting framework across multiple AWS accounts.

## Usage

### Variables

#### Required
* `slack_webhook_key` - The key for your Slack webhook. This is the part of the webhook url after '/services/'.  Consider this a 'secret'.  As such, it is STRONGLY advised not to commit this into the repository, but instead use a ParameterStore data resource to retrieve the data.  Similarly, do not commit the terraform state files, but store them in an encrypted bucket.
* `slack_channel_default` - Default channel where messages should be sent

## Maintainers

This repository is maintained by the United States Small Business Administration (SBA).  As part of the Code.gov initiative...
