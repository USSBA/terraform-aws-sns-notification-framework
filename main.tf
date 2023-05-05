data "aws_region" "current" {}

#--------------------------------------------------
# MODULE INPUT VARIABLES
#--------------------------------------------------

#required
variable "name_prefix" {
  type        = string
  description = "Required, A short and unique name prefix used to label resources."
}
variable "webhook_url_green" {
  type        = string
  description = "Required, A Microsoft Teams WebHook URI."
}
variable "webhook_url_yellow" {
  type        = string
  description = "Required, A Microsoft Teams WebHook URI."
}
variable "webhook_url_red" {
  type        = string
  description = "Required, A Microsoft Teams WebHook URI."
}
variable "webhook_url_security" {
  type        = string
  description = "Required, A Microsoft Teams WebHook URI."
}

# optional
variable "email_from" {
  type        = string
  description = "Optional, An email address representing the sender."
  default     = "undefined"
}
variable "email_to" {
  type        = string
  description = "Optional, An email address representing the recipient."
  default     = "undefined"
}
variable "log_group_retention_in_days" {
  type        = number
  description = "Optional, The number of days to retain CloudWatch logs."
  default     = 90
}

#--------------------------------------------------
# MODULE OUTPUT VARIABLES
#--------------------------------------------------
output "topics" {
  value = aws_sns_topic.topics
}
output "iam_role" {
  value = aws_iam_role.lambda
}
output "log_group" {
  value = aws_cloudwatch_log_group.lambda
}
output "lambda_function" {
  value = aws_lambda_function.lambda
}

#--------------------------------------------------
# MODULE SETTINGS: STATIC
#--------------------------------------------------
locals {
  topic_colors = ["green", "yellow", "red", "security"]
}

#--------------------------------------------------
# TOPIC CONFIG
#--------------------------------------------------
resource "aws_sns_topic" "topics" {
  count = length(local.topic_colors)
  name  = "${var.name_prefix}-teams-${local.topic_colors[count.index]}-notifications"

  # Note:
  # In the event we ever need to place a delivery policy on the topic

  #https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html
  #delivery_policy = jsonencode({
  #  http = {
  #    defaultHealthyRetryPolicy = {
  #      minDelayTarget     = 20
  #      maxDelayTarget     = 20
  #      numRetries         = 3
  #      numMaxDelayRetries = 0
  #      numNoDelayRetries  = 0
  #      numMinDelayRetries = 0
  #      backoffFunction    = "linear"
  #    }
  #    disableSubscriptionOverrides = false
  #    defaultThrottlePolicy = {
  #      maxReceivesPerSecond = 1
  #    }
  #  }
  #})
}

#--------------------------------------------------
# LAMBDA CONFIG
#--------------------------------------------------

# service linked policy
data "aws_iam_policy_document" "lambda_principal" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# custom set of permission the lambda function will be allowed to perform
data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
    ]
    resources = [
      "*",
    ]
  }
}

# role assigned to the lambda function incorporating both the service linked principals and a custom set of permissions
resource "aws_iam_role" "lambda" {
  name               = "${var.name_prefix}-teams-notifications"
  assume_role_policy = data.aws_iam_policy_document.lambda_principal.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
  inline_policy {
    name   = "execution"
    policy = data.aws_iam_policy_document.lambda.json
  }
}

resource "random_uuid" "source_hash" {
  keepers = {
    sha = join(",", [
      filebase64sha256("${path.module}/lambda_function/handler.py"),
      filebase64sha256("${path.module}/lambda_function/templates/cloudwatch.json"),
      filebase64sha256("${path.module}/lambda_function/templates/cloudwatch.txt"),
      filebase64sha256("${path.module}/lambda_function/templates/cloudwatch.html"),
      filebase64sha256("${path.module}/lambda_function/templates/default.json"),
      filebase64sha256("${path.module}/lambda_function/templates/default.txt"),
      filebase64sha256("${path.module}/lambda_function/templates/default.html"),
    ])
  }
}

# only trigger when the contents of a file within the package is changed
resource "null_resource" "zip" {
  triggers = {
    uuid = random_uuid.source_hash.result
  }
  provisioner "local-exec" {
    command = "([ -f ${path.module}/${random_uuid.source_hash.result}.zip ] && rm ${path.module}/${random_uuid.source_hash.result}.zip); cd ${path.module}/lambda_function/ && zip ../${random_uuid.source_hash.result}.zip handler.py templates/cloudwatch.json templates/cloudwatch.txt templates/cloudwatch.html templates/default.json templates/default.txt templates/default.html && cd .."
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_iam_role.lambda.name}"
  retention_in_days = var.log_group_retention_in_days
}

resource "aws_lambda_function" "lambda" {
  depends_on = [random_uuid.source_hash, null_resource.zip, aws_cloudwatch_log_group.lambda]

  function_name = aws_iam_role.lambda.name
  description   = "Forward notifications to Microsoft Teams"
  role          = aws_iam_role.lambda.arn
  filename      = "${path.module}/${random_uuid.source_hash.result}.zip"
  handler       = "handler.lambda_handler"
  memory_size   = 128 #MB
  timeout       = 10  #seconds
  runtime       = "python3.9"

  environment {
    variables = {
      EMAIL_FROM             = var.email_from
      EMAIL_TO               = var.email_to
      TEAMS_WEBHOOK_GREEN    = var.webhook_url_green
      TEAMS_WEBHOOK_YELLOW   = var.webhook_url_yellow
      TEAMS_WEBHOOK_RED      = var.webhook_url_red
      TEAMS_WEBHOOK_SECURITY = var.webhook_url_security
    }
  }
}

# allows the sns topic to invoke the lambda function when it needs to forward an alert
resource "aws_lambda_permission" "lambda" {
  count = length(local.topic_colors)

  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  function_name = aws_lambda_function.lambda.function_name
  source_arn    = aws_sns_topic.topics[count.index].arn
}

#subscribe each of the topics to the lamdba function
resource "aws_sns_topic_subscription" "lambda" {
  count = length(local.topic_colors)

  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda.arn
  topic_arn = aws_sns_topic.topics[count.index].arn
}

