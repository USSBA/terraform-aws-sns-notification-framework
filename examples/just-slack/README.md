# Just Slack

## Deployment

Note: There is a [long-standing bug](https://github.com/terraform-aws-modules/terraform-aws-notify-slack/issues/46) with the [Notify Slack](https://github.com/terraform-aws-modules/terraform-aws-notify-slack/) module which requires the SNS Topics to be created before passing into the module.  The only way around this is to target the sns topics first, then deploy the rest.  `terraform apply -target module.sns.aws_sns_topics.sns`
