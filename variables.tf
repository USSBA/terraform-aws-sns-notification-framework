variable "name_prefix" {
  type        = string
  default     = "alerting-framework"
  description = "Optional. A prefix for named services to avoid naming conflicts if deployed twice in the same account."
}
variable "default_teams_webhook_url" {
  type        = string
  description = "The URL for your Microsoft Teams webhook.  This includes 'https://'. Consider this a 'secret'.  As such, it is STRONGLY advised not to commit this into the repository, but instead use a ParameterStore data resource to retrieve the data.  Similarly, do not commit the terraform state files, but store them in an encrypted bucket."
  default     = ""
  sensitive   = true
}
variable "green_overrides" {
  description = "Configure any green-specific values here.  Removing the 'default_' from other vars to override.  {teams_webhook_url}"
  default     = {}
}
variable "yellow_overrides" {
  description = "Configure any yellow-specific values here.  Removing the 'default_' from other vars to override.  {teams_webhook_url}"
  default     = {}
}
variable "red_overrides" {
  description = "Configure any red-specific values here.  Removing the 'default_' from other vars to override.  {teams_webhook_url}"
  default     = {}
}
variable "security_overrides" {
  description = "Configure any security-specific values here.  Removing the 'default_' from other vars to override.  {teams_webhook_url}"
  default     = {}
}
variable "cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in log group for Lambda."
  type        = number
  default     = 0
}
