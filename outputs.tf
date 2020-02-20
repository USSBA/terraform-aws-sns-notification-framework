output "sns_yellow" {
  value = var.enabled ? aws_sns_topic.yellow[0] : null
}
output "sns_red" {
  value = var.enabled ? aws_sns_topic.red[0] : null
}
output "sns_security" {
  value = var.enabled ? aws_sns_topic.security[0] : null
}
output "sns_green" {
  value = var.enabled ? aws_sns_topic.green[0] : null
}
output "sns_email_admins" {
  value = var.enabled ? aws_sns_topic.email_admins[0] : null
}

output "lambda_yellow_arn" {
  value = var.enabled ? module.notify_slack_yellow.notify_slack_lambda_function_arn : null
}
output "lambda_red_arn" {
  value = var.enabled ? module.notify_slack_red.notify_slack_lambda_function_arn : null
}
output "lambda_security_arn" {
  value = var.enabled ? module.notify_slack_security.notify_slack_lambda_function_arn : null
}
output "lambda_green_arn" {
  value = var.enabled ? module.notify_slack_green.notify_slack_lambda_function_arn : null
}
