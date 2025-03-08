run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "test_vpc_event" {
  variables {
    region = run.setup.region
    name   = "test-s3-public-access-events"
    suffix = run.setup.suffix

    eventbridge_rules = [
      {
        name        = "s3-public-access-change"
        description = "Detect when S3 bucket public access settings are modified"
        event_pattern = jsonencode({
          source        = ["aws.s3"],
          "detail-type" = ["AWS API Call via CloudTrail"],
          detail = {
            eventSource = ["s3.amazonaws.com"],
            eventName   = ["PutBucketPublicAccessBlock", "PutBucketAcl"]
          }
        })
        enable_rule = true
      }
    ]

    slack_webhook_url = var.slack_webhook_url
    message_title     = "S3 Public Access Change Event"
    message_fields = join(",", [
      "time",
      "detail-type",
      "detail.eventName",
      "detail.requestParameters.bucketName",
      "detail.userIdentity.arn",
      "detail.sourceIPAddress",
      "region"
    ])
    status_colors = join(",", [
      "PUBLIC_ACCESS_MODIFIED:#FFCC00",
      "ACL_CHANGED:#E01E5A"
    ])
    status_field = "detail.eventName"
    status_mapping = join(",", [
      "PutBucketPublicAccessBlock:PUBLIC_ACCESS_MODIFIED",
      "PutBucketAcl:ACL_CHANGED"
    ])

    log_retention_days = 1

    tags = {
      Environment = "test"
      Project     = "example-project"
    }
  }

  assert {
    condition     = aws_sqs_queue.queue.name == "test-s3-public-access-events-${run.setup.suffix}"
    error_message = "SQS queue name does not match expected value."
  }

  assert {
    condition     = aws_sqs_queue.dlq.name == "test-s3-public-access-events-${run.setup.suffix}-dlq"
    error_message = "SQS queue name does not match expected value."
  }

  assert {
    condition     = aws_cloudwatch_event_rule.this["s3-public-access-change"].name == "test-s3-public-access-events-${run.setup.suffix}-s3-public-access-change"
    error_message = "CloudWatch EventBridge rule name does not match expected value."
  }

  assert {
    condition     = aws_cloudwatch_event_target.this["s3-public-access-change"].arn == aws_sqs_queue.queue.arn
    error_message = "EventBridge target ARN does not match expected SQS queue ARN."
  }

  assert {
    condition     = aws_lambda_function.queue.function_name == "test-s3-public-access-events-${run.setup.suffix}-slack-notify"
    error_message = "Lambda function name for queue does not match expected value."
  }

  assert {
    condition     = aws_lambda_function.dlq.function_name == "test-s3-public-access-events-${run.setup.suffix}-slack-notify-dlq"
    error_message = "Lambda function name for DLQ does not match expected value."
  }

  assert {
    condition     = aws_lambda_event_source_mapping.queue.event_source_arn == aws_sqs_queue.queue.arn
    error_message = "Lambda event source mapping for queue does not match expected ARN."
  }

  assert {
    condition     = aws_lambda_event_source_mapping.dlq.event_source_arn == aws_sqs_queue.dlq.arn
    error_message = "Lambda event source mapping for DLQ does not match expected ARN."
  }

  assert {
    condition     = aws_iam_role.lambda.name == "test-s3-public-access-events-${run.setup.suffix}"
    error_message = "IAM role name does not match expected value."
  }

  assert {
    condition     = aws_iam_policy.lambda.name == "test-s3-public-access-events-${run.setup.suffix}"
    error_message = "IAM policy name does not match expected value."
  }

  assert {
    condition     = aws_cloudwatch_log_group.queue.name == "/aws/lambda/test-s3-public-access-events-${run.setup.suffix}-slack-notify"
    error_message = "CloudWatch log group for queue does not match expected value."
  }

  assert {
    condition     = aws_cloudwatch_log_group.dlq.name == "/aws/lambda/test-s3-public-access-events-${run.setup.suffix}-slack-notify-dlq"
    error_message = "CloudWatch log group for DLQ does not match expected value."
  }
}
