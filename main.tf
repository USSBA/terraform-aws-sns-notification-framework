# SNS Topics
locals {
  channel_config = {
    green = {
      teams_webhook_url = try(var.green_overrides.teams_webhook_url, var.default_teams_webhook_url)
    }
    yellow = {
      teams_webhook_url = try(var.yellow_overrides.teams_webhook_url, var.default_teams_webhook_url)
    }
    red = {
      teams_webhook_url = try(var.red_overrides.teams_webhook_url, var.default_teams_webhook_url)
    }
    security = {
      teams_webhook_url = try(var.security_overrides.teams_webhook_url, var.default_teams_webhook_url)
    }
  }
  # Create a set that contains only the ["color"] that are configured with a non-empty *_webhook_url
  # Wrap this in nonsensitive because the name list is... not sensitive
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

module "notify_teams" {
  for_each = local.teams_colors
  source   = "./modules/teams-webhook/"

  sns_topic_arn        = aws_sns_topic.topics[each.key].arn
  teams_webhook_url    = local.channel_config[each.key].teams_webhook_url
  lambda_function_name = "${var.name_prefix}-notify-teams-${each.key}"

  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
}
