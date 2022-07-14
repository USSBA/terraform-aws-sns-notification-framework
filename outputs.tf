output "sns_topics" {
  value = merge(aws_sns_topic.topics, { email_admins = aws_sns_topic.email_admins })
}

# Retaining old outputs for backwards compatibility, but new dev should use sns_topics["green"], etc
output "sns_green" {
  value = aws_sns_topic.topics["green"]
}
output "sns_yellow" {
  value = aws_sns_topic.topics["yellow"]
}
output "sns_red" {
  value = aws_sns_topic.topics["red"]
}
output "sns_security" {
  value = aws_sns_topic.topics["security"]
}

output "teams_lambda_arns" {
  value = { for key, value in module.notify_teams : key => value.lambda_arn }
}
