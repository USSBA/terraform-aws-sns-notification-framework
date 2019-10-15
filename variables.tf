variable "slack_webhook_key" {
  type = string
  description = "The key for your Slack webhook. This is the part of the webhook url after '/services/'.  Consider this a 'secret'.  As such, it is STRONGLY advised not to commit this into the repository, but instead use a ParameterStore data resource to retrieve the data.  Similarly, do not commit the terraform state files, but store them in an encrypted bucket."
}
variable "slack_channel_default" {
  type = string
  description = "Default channel where messages should be sent"
}
variable "name_prefix" {
  type = string
  default = "alerting-framework"
  description = "Optional. A prefix for named services to avoid naming conflicts if deployed twice in the same account."
}
variable "slack_channel_red_override" {
  type = string
  default = ""
  description = "Optional.  Override channel for red messages"
}
variable "slack_channel_yellow_override" {
  type = string
  default = ""
  description = "Optional.  Override channel for yellow messages"
}
variable "slack_channel_green_override" {
  type = string
  default = ""
  description = "Optional.  Override channel for green messages"
}
variable "slack_channel_security_override" {
  type = string
  default = ""
  description = "Optional.  Override channel for security messages"
}
