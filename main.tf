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

## This comes from a public terraform module:  https://registry.terraform.io/modules/terraform-aws-modules/notify-slack/aws/2.0.0
module "notify_slack" {
  # Create a map that contains only the ["color"] that are configured with a non-empty slack_webhook_url
  for_each = { for name, config in local.channel_config : name => config if config.slack_webhook_url != "" }
  source   = "terraform-aws-modules/notify-slack/aws"
  version  = "~> 4.11"

  slack_channel                          = each.value.slack_channel
  slack_username                         = each.value.slack_username
  slack_webhook_url                      = each.value.slack_webhook_url
  slack_emoji                            = each.value.slack_emoji
  sns_topic_name                         = aws_sns_topic.topics[each.key].name
  create_sns_topic                       = false
  lambda_function_name                   = "${var.name_prefix}-notify-slack-${each.key}"
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
}

module "notify_teams" {
  # Create a map that contains only the ["color"] that are configured with a non-empty slack_webhook_url
  for_each = { for name, config in local.channel_config : name => config if config.teams_webhook_url != "" }
  source   = "./modules/teams-webhook/"

  sns_topic_arn        = aws_sns_topic.topics[each.key].arn
  teams_webhook_url    = each.value.teams_webhook_url
  lambda_function_name = "${var.name_prefix}-notify-teams-${each.key}"
}
