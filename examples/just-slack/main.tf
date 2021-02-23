# Pre-populate parameter store with your Teams webhook URL
data "aws_ssm_parameter" "sns_topic_slack_webhook" {
  name = "/slack/webhooks/test_url"
}
module "sns" {
  #source  = "USSBA/sns-notification-framework/aws"
  #version = "~> 2.1"
  source = "../../"

  name_prefix               = "sns-webhook-framework-just-slack"
  default_slack_webhook_url = data.aws_ssm_parameter.sns_topic_slack_webhook.value
  default_slack_channel     = "automated_spam"
  default_slack_emoji       = ":sleepy:"

  red_overrides = {
    slack_emoji    = ":red_circle:"
    slack_channel  = "very_important_stuff"
    slack_username = "HEY Y'ALL IMPORTANT STUFF HERE"
  }
  security_overrides = {
    slack_emoji = ":lock:"
  }

  cloudwatch_log_group_retention_in_days = 90
}

output "sns_topics" {
  value = module.sns.sns_topics
}
