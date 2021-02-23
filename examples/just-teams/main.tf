# Pre-populate parameter store with your Teams webhook URL
data "aws_ssm_parameter" "sns_topic_teams_webhook" {
  name = "/teams/webhooks/test_url"
}
module "sns" {
  #source  = "USSBA/sns-notification-framework/aws"
  #version = "~> 2.1"
  source = "../../"

  name_prefix               = "sns-webhook-framework-just-teams"
  default_teams_webhook_url = data.aws_ssm_parameter.sns_topic_teams_webhook.value

  cloudwatch_log_group_retention_in_days = 90
}

output "sns_topics" {
  value = module.sns.sns_topics
}
