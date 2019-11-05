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
