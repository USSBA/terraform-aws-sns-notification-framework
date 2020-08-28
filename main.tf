locals {
  enabled_count = var.enabled ? 1 : 0
}
# SNS Topics
resource "aws_sns_topic" "green" {
  count = local.enabled_count
  name  = "${var.name_prefix}-green"
}
resource "aws_sns_topic" "yellow" {
  count = local.enabled_count
  name  = "${var.name_prefix}-yellow"
}
resource "aws_sns_topic" "red" {
  count = local.enabled_count
  name  = "${var.name_prefix}-red"
}
resource "aws_sns_topic" "security" {
  count = local.enabled_count
  name  = "${var.name_prefix}-security"
}
resource "aws_sns_topic" "email_admins" {
  count = local.enabled_count
  name  = "${var.name_prefix}-email-admins"
  # After this resource is created, go to AWS Console and subscribe the following email addresses
  #    https://console.aws.amazon.com/sns/v3/home?region=us-east-1#/topics
  # - #TODO: addresses TBD
}

# This comes from a public terraform module:  https://registry.terraform.io/modules/terraform-aws-modules/notify-slack/aws/2.0.0
module "notify_slack_green" {
  create  = var.enabled
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "4.1.0"
  # insert the 4 required variables here
  slack_channel        = length(var.slack_channel_green_override) > 0 ? var.slack_channel_green_override : var.slack_channel_default
  slack_username       = "AWS Green SNS"
  slack_webhook_url    = "https://hooks.slack.com/services/${var.slack_webhook_key}"
  sns_topic_name       = var.enabled ? aws_sns_topic.green[0].name : ""
  create_sns_topic     = false
  slack_emoji          = ":information_source:"
  lambda_function_name = "${var.name_prefix}-notify-slack-green"
}

# This comes from a public terraform module:  https://registry.terraform.io/modules/terraform-aws-modules/notify-slack/aws/2.0.0
module "notify_slack_yellow" {
  create  = var.enabled
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "4.1.0"
  # insert the 4 required variables here
  slack_channel        = length(var.slack_channel_yellow_override) > 0 ? var.slack_channel_yellow_override : var.slack_channel_default
  slack_username       = "AWS Yellow SNS"
  slack_webhook_url    = "https://hooks.slack.com/services/${var.slack_webhook_key}"
  sns_topic_name       = var.enabled ? aws_sns_topic.yellow[0].name : ""
  create_sns_topic     = false
  slack_emoji          = ":warning:"
  lambda_function_name = "${var.name_prefix}-notify-slack-yellow"
}

# This comes from a public terraform module:  https://registry.terraform.io/modules/terraform-aws-modules/notify-slack/aws/2.0.0
module "notify_slack_red" {
  create  = var.enabled
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "4.1.0"
  # insert the 4 required variables here
  slack_channel        = length(var.slack_channel_red_override) > 0 ? var.slack_channel_red_override : var.slack_channel_default
  slack_username       = "AWS Red SNS"
  slack_webhook_url    = "https://hooks.slack.com/services/${var.slack_webhook_key}"
  sns_topic_name       = var.enabled ? aws_sns_topic.red[0].name : ""
  create_sns_topic     = false
  slack_emoji          = ":alert:"
  lambda_function_name = "${var.name_prefix}-notify-slack-red"
}

# This comes from a public terraform module:  https://registry.terraform.io/modules/terraform-aws-modules/notify-slack/aws/2.0.0
module "notify_slack_security" {
  create  = var.enabled
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "4.1.0"
  # insert the 4 required variables here
  slack_channel        = length(var.slack_channel_security_override) > 0 ? var.slack_channel_security_override : var.slack_channel_default
  slack_username       = "AWS Security SNS"
  slack_webhook_url    = "https://hooks.slack.com/services/${var.slack_webhook_key}"
  sns_topic_name       = var.enabled ? aws_sns_topic.security[0].name : ""
  create_sns_topic     = false
  slack_emoji          = ":lock:"
  lambda_function_name = "${var.name_prefix}-notify-slack-security"
}
