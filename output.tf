output "sqs_queue_url" {
  description = "URL of the main SQS queue"
  value       = aws_sqs_queue.queue.url
}

output "sqs_queue_arn" {
  description = "ARN of the main SQS queue"
  value       = aws_sqs_queue.queue.arn
}

output "sqs_dlq_url" {
  description = "URL of the Dead Letter Queue (DLQ)"
  value       = aws_sqs_queue.dlq.url
}

output "sqs_dlq_arn" {
  description = "ARN of the Dead Letter Queue (DLQ)"
  value       = aws_sqs_queue.dlq.arn
}

output "eventbridge_rule_arns" {
  description = "ARNs of the created EventBridge rules"
  value       = { for k, v in aws_cloudwatch_event_rule.this : k => v.arn }
}

output "lambda_queue_arn" {
  description = "ARN of the Lambda function processing the main SQS queue"
  value       = aws_lambda_function.queue.arn
}

output "lambda_dlq_arn" {
  description = "ARN of the Lambda function processing the DLQ"
  value       = aws_lambda_function.dlq.arn
}

output "lambda_queue_function_name" {
  description = "Function name of the Lambda processing the main SQS queue"
  value       = aws_lambda_function.queue.function_name
}

output "lambda_dlq_function_name" {
  description = "Function name of the Lambda processing the DLQ"
  value       = aws_lambda_function.dlq.function_name
}

output "cloudwatch_log_group_queue" {
  description = "CloudWatch log group name for the main Lambda function"
  value       = aws_cloudwatch_log_group.queue.name
}

output "cloudwatch_log_group_dlq" {
  description = "CloudWatch log group name for the DLQ Lambda function"
  value       = aws_cloudwatch_log_group.dlq.name
}

output "iam_role_lambda_arn" {
  description = "IAM Role ARN assigned to the Lambda function"
  value       = aws_iam_role.lambda.arn
}
