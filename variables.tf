variable "name_prefix" {
  type        = string
  default     = "alerting-framework"
  description = "Optional. A prefix for named services to avoid naming conflicts if deployed twice in the same account."
}
variable "default_teams_webhook_url" {
  type        = string
  description = "The URL for your Microsoft Teams webhook.  This includes 'https://'. Consider this a 'secret'.  As such, it is STRONGLY advised not to commit this into the repository, but instead use a ParameterStore data resource to retrieve the data.  Similarly, do not commit the terraform state files, but store them in an encrypted bucket."
  default     = ""
}
variable "default_slack_webhook_url" {
  type        = string
  description = "The URL for your Slack webhook. This includes 'https://'.  Consider this a 'secret'.  As such, it is STRONGLY advised not to commit this into the repository, but instead use a ParameterStore data resource to retrieve the data.  Similarly, do not commit the terraform state files, but store them in an encrypted bucket."
  default     = ""
}
variable "default_slack_channel" {
  type        = string
  description = "Default channel where messages should be sent. Required if slack_webhook_key is provided"
  default     = ""
}
variable "default_slack_emoji" {
  type        = string
  description = "Slack emoji to act as the avatar for messages, surrounded by colons `:`.  Default defers to color-specific overrides.  Setting this will take precedence over the deferred defaults."
  default     = ""
}
variable "default_slack_username" {
  type        = string
  description = "Username that shows up for Slack messages. This var will be suffixed with ' <type>' (such as Red, Green).  Default is 'AWS SNS <type>'."
  default     = "AWS SNS"
}
variable "green_overrides" {
  description = "Configure any green-specific values here.  Removing the 'default_' from other vars to override.  {slack_webhook_url, slack_channel, slack_emoji, slack_username, teams_webhook_url}"
  default     = {}
}
variable "yellow_overrides" {
  description = "Configure any yellow-specific values here.  Removing the 'default_' from other vars to override.  {slack_webhook_url, slack_channel, slack_emoji, slack_username, teams_webhook_url}"
  default     = {}
}
variable "red_overrides" {
  description = "Configure any red-specific values here.  Removing the 'default_' from other vars to override.  {slack_webhook_url, slack_channel, slack_emoji, slack_username, teams_webhook_url}"
  default     = {}
}
variable "security_overrides" {
  description = "Configure any security-specific values here.  Removing the 'default_' from other vars to override.  {slack_webhook_url, slack_channel, slack_emoji, slack_username, teams_webhook_url}"
  default     = {}
}
variable "cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in log group for Lambda."
  type        = number
  default     = 0
}
