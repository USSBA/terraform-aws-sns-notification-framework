# SNS Topics
locals {
  channel_config = {
    green = {
      slack_channel     = try(var.green_overrides.slack_channel, var.default_slack_channel)
      slack_webhook_url = try(var.green_overrides.slack_webhook_url, var.default_slack_webhook_url)
      slack_emoji       = try(var.green_overrides.slack_emoji, var.default_slack_emoji != "" ? var.default_slack_emoji : ":large_green_circle:")
      slack_username    = try(var.green_overrides.slack_username, "${var.default_slack_username} Green")
      teams_webhook_url = try(var.green_overrides.teams_webhook_url, var.default_teams_webhook_url)
    }
    yellow = {
      slack_channel     = try(var.yellow_overrides.slack_channel, var.default_slack_channel)
      slack_webhook_url = try(var.yellow_overrides.slack_webhook_url, var.default_slack_webhook_url)
      slack_emoji       = try(var.yellow_overrides.slack_emoji, var.default_slack_emoji != "" ? var.default_slack_emoji : ":large_yellow_circle:")
      slack_username    = try(var.yellow_overrides.slack_username, "${var.default_slack_username} Yellow")
      teams_webhook_url = try(var.yellow_overrides.teams_webhook_url, var.default_teams_webhook_url)
    }
    red = {
      slack_channel     = try(var.red_overrides.slack_channel, var.default_slack_channel)
      slack_webhook_url = try(var.red_overrides.slack_webhook_url, var.default_slack_webhook_url)
      slack_emoji       = try(var.red_overrides.slack_emoji, var.default_slack_emoji != "" ? var.default_slack_emoji : ":red_circle:")
      slack_username    = try(var.red_overrides.slack_username, "${var.default_slack_username} Red")
      teams_webhook_url = try(var.red_overrides.teams_webhook_url, var.default_teams_webhook_url)
    }
    security = {
      slack_channel     = try(var.security_overrides.slack_channel, var.default_slack_channel)
      slack_webhook_url = try(var.security_overrides.slack_webhook_url, var.default_slack_webhook_url)
      slack_emoji       = try(var.security_overrides.slack_emoji, var.default_slack_emoji != "" ? var.default_slack_emoji : ":lock:")
      slack_username    = try(var.security_overrides.slack_username, "${var.default_slack_username} Security")
      teams_webhook_url = try(var.security_overrides.teams_webhook_url, var.default_teams_webhook_url)
    }
  }
  # Create a set that contains only the ["color"] that are configured with a non-empty *_webhook_url
  # Wrap this in nonsensitive because the name list is... not sensitive
  slack_colors = toset(nonsensitive([for name in keys(local.channel_config) : name if local.channel_config[name].slack_webhook_url != ""]))
  teams_colors = toset(nonsensitive([for name in keys(local.channel_config) : name if local.channel_config[name].teams_webhook_url != ""]))
}
resource "aws_sns_topic" "topics" {
  for_each = local.channel_config
  name     = "${var.name_prefix}-${each.key}"
}

resource "aws_sns_topic" "email_admins" {
  name = "${var.name_prefix}-email-admins"
  # After this resource is created, go to AWS Console and subscribe the following email addresses
  #    https://console.aws.amazon.com/sns/v3/home?region=us-east-1#/topics
  # - #TODO: addresses TBD
}

## This comes from a public terraform module:  https://registry.terraform.io/modules/terraform-aws-modules/notify-slack
module "notify_slack" {
  for_each = local.slack_colors
  source   = "terraform-aws-modules/notify-slack/aws"
  version  = "~> 5.0"

  slack_channel        = local.channel_config[each.key].slack_channel
  slack_username       = local.channel_config[each.key].slack_username
  slack_webhook_url    = local.channel_config[each.key].slack_webhook_url
  slack_emoji          = local.channel_config[each.key].slack_emoji
  sns_topic_name       = aws_sns_topic.topics[each.key].name
  create_sns_topic     = false
  lambda_function_name = "${var.name_prefix}-notify-slack-${each.key}"

  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
}

module "notify_teams" {
  for_each = local.teams_colors
  source   = "./modules/teams-webhook/"

  sns_topic_arn        = aws_sns_topic.topics[each.key].arn
  teams_webhook_url    = local.channel_config[each.key].teams_webhook_url
  lambda_function_name = "${var.name_prefix}-notify-teams-${each.key}"

  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
}
