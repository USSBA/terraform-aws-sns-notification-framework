data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

#--------------------------------------------------
# MODULE INPUT VARIABLES
#--------------------------------------------------

#required
variable "name_prefix" {
  type        = string
  description = "Required, A short and unique name prefix used to label resources."
}
variable "email_from" {
  type        = string
  description = "Required, An email address representing the sender."
}
variable "email_to" {
  type        = string
  description = "Required, a comma-seperated list of email addresses representing the recipients."
}
variable "log_group_retention_in_days" {
  type        = number
  description = "Optional, The number of days to retain CloudWatch logs."
  default     = 90
}
variable "encrypted" {
  type        = bool
  description = "Optional, Should the topics support encryption at rest."
  default     = false
}
variable "kms_key_alias" {
  type        = string
  description = "Optional, The alias name for the KMS managed key. Requires var.encrypted == true."
  default     = ""
}

#--------------------------------------------------
# MODULE OUTPUT VARIABLES
#--------------------------------------------------

output "topic" {
  value = aws_sns_topic.topic
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

#locals {
#  topic_colors = ["red"]
#}

#--------------------------------------------------
# TOPIC CONFIG
#--------------------------------------------------
resource "aws_sns_topic" "topic" {
  name              = "${var.name_prefix}-email-notifications"
  kms_master_key_id = try(var.encrypted ? aws_kms_key.key[0].arn : null, null)
}

data "aws_iam_policy_document" "topic_policy" {
  statement {
    sid = "aws-cloudwatch"
    actions = [
      "sns:Publish",
    ]
    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com"
      ]
    }
    resources = [
      aws_sns_topic.topic.arn
    ]
  }
  statement {
    sid = "aws-backup"
    actions = [
      "sns:Publish",
      "sns:Subscribe",
    ]
    principals {
      type = "Service"
      identifiers = [
        "backup.amazonaws.com"
      ]
    }
    resources = [
      aws_sns_topic.topic.arn
    ]
  }
}

resource "aws_sns_topic_policy" "topic_policy" {
  arn    = aws_sns_topic.topic.arn
  policy = data.aws_iam_policy_document.topic_policy.json
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
  name               = "${var.name_prefix}-sns-framework"
  assume_role_policy = data.aws_iam_policy_document.lambda_principal.json
}

resource "aws_iam_role_policy_attachments_exclusive" "lambda" {
  role_name = aws_iam_role.lambda.name
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${var.name_prefix}-sns-framework"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policies_exclusive" "lambda" {
  role_name = aws_iam_role.lambda.name
  policy_names = [
    aws_iam_role_policy.lambda.name
  ]
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_iam_role.lambda.name}"
  retention_in_days = var.log_group_retention_in_days
}

resource "aws_lambda_function" "lambda" {
  depends_on = [aws_cloudwatch_log_group.lambda]

  function_name = aws_iam_role.lambda.name
  description   = "Forward notifications to email addresses."
  role          = aws_iam_role.lambda.arn
  filename      = "${path.module}/function.zip"
  handler       = "handler.lambda_handler"
  memory_size   = 128 #MB
  timeout       = 10  #seconds
  runtime       = "python3.9"

  environment {
    variables = {
      EMAIL_FROM = var.email_from
      EMAIL_TO   = var.email_to
    }
  }
}

# allows the sns topic to invoke the lambda function when it needs to forward an alert
resource "aws_lambda_permission" "lambda" {
  action        = "lambda:InvokeFunction"
  principal     = "sns.amazonaws.com"
  function_name = aws_lambda_function.lambda.function_name
  source_arn    = aws_sns_topic.topic.arn
}

#subscribe each of the topics to the lamdba function
resource "aws_sns_topic_subscription" "lambda" {
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda.arn
  topic_arn = aws_sns_topic.topic.arn
}


resource "archive_file" "init" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function/"
  output_path = "${path.module}/function.zip"
}
#--------------------------------------------------
# KMS CONFIG
#--------------------------------------------------

resource "aws_kms_key" "key" {
  count = var.encrypted ? 1 : 0

  policy = data.aws_iam_policy_document.key[0].json
}

resource "aws_kms_alias" "key" {
  count = var.encrypted ? 1 : 0

  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.key[0].key_id
}

data "aws_iam_policy_document" "key" {
  count = var.encrypted ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:DescribeKey",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["sns.us-east-1.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]
    resources = ["*"]
  }
}
