# ----------------------------------------
# Data Sources
# ----------------------------------------
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ----------------------------------------
# Local Variables
# ----------------------------------------
locals {
  base_name = length(var.suffix) > 0 ? "${var.name}-${var.suffix}" : var.name

  files_queue = fileset("${path.module}/external/queue", "**")
  hash_queue = md5(
    join(
      "",
      [for f in local.files_queue : "${f}:${filemd5("${path.module}/external/queue/${f}")}"]
    )
  )
}

# ----------------------------------------
# SQS Queues and Policies
# ----------------------------------------
resource "aws_sqs_queue" "queue" {
  name                      = local.base_name
  message_retention_seconds = var.sqs_defaults.message_retention_seconds
  tags                      = merge(var.tags, { Name = local.base_name })
}

resource "aws_sqs_queue" "dlq" {
  name                      = "${local.base_name}-dlq"
  message_retention_seconds = var.dlq_defaults.message_retention_seconds
  tags                      = merge(var.tags, { Name = "${local.base_name}-dlq" })
}

resource "aws_sqs_queue_redrive_policy" "queue" {
  queue_url = aws_sqs_queue.queue.url
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.dlq_defaults.max_receive_count
  })
}

resource "aws_sqs_queue_policy" "queue" {
  queue_url = aws_sqs_queue.queue.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.queue.arn
      },
      {
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = [for rule in values(aws_cloudwatch_event_rule.this) : rule.arn]
          }
        }
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_sqs_queue.queue]
}

# ----------------------------------------
# CloudWatch EventBridge Rules and Targets
# ----------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for rule in var.eventbridge_rules : rule.name => rule }

  name          = "${local.base_name}-${each.value.name}"
  description   = each.value.description
  event_pattern = each.value.event_pattern
  state         = lookup(each.value, "enable_rule", true) ? "ENABLED" : "DISABLED"

  tags = merge(var.tags, { Name = "${local.base_name}-${each.value.name}" })
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = aws_cloudwatch_event_rule.this
  rule     = each.value.name
  arn      = aws_sqs_queue.queue.arn
}

# ----------------------------------------
# Lambda Function Configuration
# ----------------------------------------
resource "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/external/queue"
  output_path = "${path.module}/external/queue.zip"
}

resource "aws_lambda_function" "queue" {
  function_name = "${local.base_name}-slack-notify"
  runtime       = "python3.13"
  handler       = "handler.lambda_handler"
  timeout       = 30
  role          = aws_iam_role.lambda.arn

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      QUEUE_URL         = aws_sqs_queue.queue.url
      MESSAGE_TITLE     = var.message_title
      MESSAGE_FIELDS    = var.message_fields
      STATUS_COLORS     = var.status_colors
      STATUS_FIELD      = var.status_field
      STATUS_MAPPING    = var.status_mapping
      DEBUG             = var.lambda_debug
    }
  }

  filename         = archive_file.this.output_path
  source_code_hash = local.hash_queue

  depends_on = [
    archive_file.this,
    aws_cloudwatch_log_group.queue
  ]

  tags = merge(var.tags, { Name = "${local.base_name}-slack-notify" })
}

resource "aws_lambda_function" "dlq" {
  function_name = "${local.base_name}-slack-notify-dlq"
  runtime       = "python3.13"
  handler       = "handler.lambda_handler"
  timeout       = 30
  role          = aws_iam_role.lambda.arn

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      QUEUE_URL         = aws_sqs_queue.dlq.url
      MESSAGE_TITLE     = var.message_title
      MESSAGE_FIELDS    = var.message_fields
      STATUS_COLORS     = var.status_colors
      STATUS_FIELD      = var.status_field
      STATUS_MAPPING    = var.status_mapping
      DEBUG             = var.lambda_debug
      IS_DLQ            = true
    }
  }

  filename         = archive_file.this.output_path
  source_code_hash = local.hash_queue

  depends_on = [
    archive_file.this,
    aws_cloudwatch_log_group.dlq
  ]

  tags = merge(var.tags, { Name = "${local.base_name}-slack-notify-dlq" })
}

# ----------------------------------------
# Lambda Event Source Mappings
# ----------------------------------------
resource "aws_lambda_event_source_mapping" "queue" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.queue.arn
  batch_size       = 1
}

resource "aws_lambda_event_source_mapping" "dlq" {
  event_source_arn = aws_sqs_queue.dlq.arn
  function_name    = aws_lambda_function.dlq.arn
  batch_size       = 1
}

# ----------------------------------------
# IAM Roles and Policies
# ----------------------------------------
resource "aws_iam_role" "lambda" {
  name = local.base_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, { Name = local.base_name })
}

resource "aws_iam_policy" "lambda" {
  name = local.base_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = [
          aws_sqs_queue.queue.arn,
          aws_sqs_queue.dlq.arn
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup"],
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.base_name}-slack-notify:log-stream:*",
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.base_name}-slack-notify-dlq:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

# ----------------------------------------
# CloudWatch Logs
# ----------------------------------------
resource "aws_cloudwatch_log_group" "queue" {
  name              = "/aws/lambda/${local.base_name}-slack-notify"
  retention_in_days = var.log_retention_days
  tags              = merge(var.tags, { Name = "${local.base_name}-slack-notify" })
}

resource "aws_cloudwatch_log_group" "dlq" {
  name              = "/aws/lambda/${local.base_name}-slack-notify-dlq"
  retention_in_days = var.log_retention_days
  tags              = merge(var.tags, { Name = "${local.base_name}-slack-notify-dlq" })
}
