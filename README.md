# terraform-aws-event-notifier-slack

Terraform module to create a generic event-driven Slack notification system

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.84.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.84.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [archive_file.this](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/resources/file) | resource |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.dlq](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.queue](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.lambda](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_event_source_mapping.dlq](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.queue](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.dlq](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lambda_function) | resource |
| [aws_lambda_function.queue](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lambda_function) | resource |
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.queue](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.queue](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/sqs_queue_policy) | resource |
| [aws_sqs_queue_redrive_policy.queue](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/sqs_queue_redrive_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dlq_defaults"></a> [dlq\_defaults](#input\_dlq\_defaults) | Default settings for the dead-letter queue (DLQ) | <pre>object({<br/>    message_retention_seconds = number<br/>    max_receive_count         = number<br/>  })</pre> | <pre>{<br/>  "max_receive_count": 5,<br/>  "message_retention_seconds": 86400<br/>}</pre> | no |
| <a name="input_eventbridge_rules"></a> [eventbridge\_rules](#input\_eventbridge\_rules) | List of EventBridge rules that share the same SQS queue | <pre>list(object({<br/>    name          = string<br/>    description   = string<br/>    event_pattern = string<br/>    enable_rule   = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Retention period for CloudWatch logs in days | `number` | `30` | no |
| <a name="input_message_fields"></a> [message\_fields](#input\_message\_fields) | Comma-separated list of message fields | `string` | n/a | yes |
| <a name="input_message_title"></a> [message\_title](#input\_message\_title) | Title of the message sent to Slack | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name for the associated resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the provider. Defaults to ap-southeast-2 if not specified. | `string` | `"ap-southeast-2"` | no |
| <a name="input_slack_webhook_url"></a> [slack\_webhook\_url](#input\_slack\_webhook\_url) | Slack Webhook URL for sending notifications | `string` | n/a | yes |
| <a name="input_sqs_defaults"></a> [sqs\_defaults](#input\_sqs\_defaults) | Default settings for the main SQS queue | <pre>object({<br/>    message_retention_seconds = number<br/>  })</pre> | <pre>{<br/>  "message_retention_seconds": 300<br/>}</pre> | no |
| <a name="input_status_colors"></a> [status\_colors](#input\_status\_colors) | Mapping of status to Slack colors | `string` | n/a | yes |
| <a name="input_status_field"></a> [status\_field](#input\_status\_field) | Field in the message that represents status | `string` | n/a | yes |
| <a name="input_status_mapping"></a> [status\_mapping](#input\_status\_mapping) | Mapping of status values to general categories | `string` | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Optional suffix for resource names | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_dlq"></a> [cloudwatch\_log\_group\_dlq](#output\_cloudwatch\_log\_group\_dlq) | CloudWatch log group name for the DLQ Lambda function |
| <a name="output_cloudwatch_log_group_queue"></a> [cloudwatch\_log\_group\_queue](#output\_cloudwatch\_log\_group\_queue) | CloudWatch log group name for the main Lambda function |
| <a name="output_eventbridge_rule_arns"></a> [eventbridge\_rule\_arns](#output\_eventbridge\_rule\_arns) | ARNs of the created EventBridge rules |
| <a name="output_iam_role_lambda_arn"></a> [iam\_role\_lambda\_arn](#output\_iam\_role\_lambda\_arn) | IAM Role ARN assigned to the Lambda function |
| <a name="output_lambda_dlq_arn"></a> [lambda\_dlq\_arn](#output\_lambda\_dlq\_arn) | ARN of the Lambda function processing the DLQ |
| <a name="output_lambda_dlq_function_name"></a> [lambda\_dlq\_function\_name](#output\_lambda\_dlq\_function\_name) | Function name of the Lambda processing the DLQ |
| <a name="output_lambda_queue_arn"></a> [lambda\_queue\_arn](#output\_lambda\_queue\_arn) | ARN of the Lambda function processing the main SQS queue |
| <a name="output_lambda_queue_function_name"></a> [lambda\_queue\_function\_name](#output\_lambda\_queue\_function\_name) | Function name of the Lambda processing the main SQS queue |
| <a name="output_sqs_dlq_arn"></a> [sqs\_dlq\_arn](#output\_sqs\_dlq\_arn) | ARN of the Dead Letter Queue (DLQ) |
| <a name="output_sqs_dlq_url"></a> [sqs\_dlq\_url](#output\_sqs\_dlq\_url) | URL of the Dead Letter Queue (DLQ) |
| <a name="output_sqs_queue_arn"></a> [sqs\_queue\_arn](#output\_sqs\_queue\_arn) | ARN of the main SQS queue |
| <a name="output_sqs_queue_url"></a> [sqs\_queue\_url](#output\_sqs\_queue\_url) | URL of the main SQS queue |
