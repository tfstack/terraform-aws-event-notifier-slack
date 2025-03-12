# Terraform Module: AWS Event Notifier for Slack

## Overview

This Terraform module sets up an AWS-based event notification system that captures AWS events, processes them via an SQS queue, and triggers a Lambda function to send notifications to Slack. It provisions the necessary AWS resources, including SQS queues, Lambda functions, IAM roles, and CloudWatch log groups.

## Features

- Creates an **SQS queue** to receive event messages.
- Configures a **Dead Letter Queue (DLQ)** for handling failed messages.
- Deploys **AWS Lambda functions** to process messages and send notifications to a Slack webhook.
- Sets up **IAM roles and policies** to ensure proper access control.
- Manages **CloudWatch Logs** for monitoring and debugging.

## Supported Event Types

> ⚠ **Disclaimer:**
> The following are just **examples** of supported event types. This module can generate a **high volume of alerts**, depending on your AWS activity and configuration. Be mindful when enabling multiple event sources to avoid excessive notifications.

This module can be used to monitor and notify on various AWS events, including but not limited to:

- **EC2 Instance State Change Events**
- **EC2 Security Group Change Events**
- **EC2 Elastic IP Activity Events**
- **EC2 Spot Instance Events**
- **AWS Support Case Events**
- **AWS Health Events**
- **EC2 Auto Scaling Events**
- **AWS Root User Login Events**
- **IAM Policy Change Events**
- **S3 Public Access Events**
- **S3 Public Access Change Events**
- **AWS VPC Events**
- **ECS Container Events**
- **ECS Task Events**
- **ECS Deployment Events**

## Usage

```hcl
module "aws_event_notifier" {
  source = "../.."

  region = data.aws_region.current.name
  name   = "s3-public-access-change"
  suffix = random_string.suffix.result

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
    "MODIFIED:#FFCC00",
    "CHANGED:#E01E5A"
  ])
  status_field = "detail.eventName"
  status_mapping = join(",", [
    "PutBucketPublicAccessBlock:MODIFIED",
    "PutBucketAcl:CHANGED"
  ])

  log_retention_days = 1

  tags = {
    Environment = "dev"
    Project     = "example-project"
  }
}
```

## Inputs

| Name                | Type   | Description |
|---------------------|--------|-------------|
| `region`            | string | AWS region for deployment |
| `name`              | string | Base name for resources |
| `suffix`            | string | Random suffix for uniqueness |
| `slack_webhook_url` | string | Slack webhook URL for notifications |
| `message_title`     | string | Title of the Slack message |
| `message_fields`    | string | Comma-separated list of fields to include in the message |
| `status_colors`     | string | Mapping of status to colors for Slack notifications |
| `status_field`      | string | JSON field used to determine status |
| `status_mapping`    | string | Mapping of event names to status labels |
| `log_retention_days` | number | Retention period for CloudWatch logs |
| `tags`              | map(string) | Additional tags for resources |

## Outputs

| Name                 | Description |
|----------------------|-------------|
| `sqs_queue_arn`      | ARN of the main SQS queue |
| `sqs_dlq_arn`        | ARN of the Dead Letter Queue |
| `lambda_function_arn` | ARN of the Slack notification Lambda function |
| `cloudwatch_log_group` | CloudWatch log group for Lambda |

## Resources Created

- **AWS SQS Queues**
  - Main event queue
  - Dead Letter Queue (DLQ)
- **AWS Lambda Functions**
  - Processes messages and sends alerts to Slack
- **IAM Roles and Policies**
  - Provides necessary permissions to Lambda and SQS
- **CloudWatch Logs**
  - Captures Lambda execution logs

## Notes

- The module is designed to integrate with various AWS EventBridge rules, but specific rule configurations should be managed separately.
- The Lambda function is deployed using Python 3.13 and expects a valid `handler.lambda_handler` entry point.

## License

MIT License
