data "archive_file" "lambda" {
  type        = "zip"
  output_path = "lambda.zip"
  source {
    content  = <<EOF
      EOF
    filename = "index.js"
  }
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 1.35"
  publish = true

  function_name                     = var.lambda_function_name
  handler                           = "notify_teams.lambda_handler"
  source_path                       = "${path.module}/functions/notify_teams.py"
  artifacts_dir                     = "${path.root}/builds"
  runtime                           = "python3.8"
  timeout                           = 30
  cloudwatch_logs_retention_in_days = var.cloudwatch_log_group_retention_in_days

  environment_variables = {
    TEAMS_WEBHOOK_URL = var.teams_webhook_url
  }

  allowed_triggers = {
    AllowExecutionFromSNS = {
      principal  = "sns.amazonaws.com"
      source_arn = var.sns_topic_arn
    }
  }
}

resource "aws_sns_topic_subscription" "sns_notify_slack" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = module.lambda.this_lambda_function_arn
}

output "lambda_arn" {
  value = module.lambda.this_lambda_function_arn
}
