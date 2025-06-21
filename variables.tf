# ----------------------------------------
# General Configuration
# ----------------------------------------
variable "suffix" {
  description = "Optional suffix for resource names"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name for the associated resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch logs in days"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 3650
    error_message = "log_retention_days must be between 1 and 3650."
  }
}

variable "lambda_debug" {
  description = "Enable debug mode for Lambda logging"
  type        = bool
  default     = false
}

# ----------------------------------------
# SQS Configuration
# ----------------------------------------

variable "sqs_defaults" {
  description = "Default settings for the main SQS queue"
  type = object({
    message_retention_seconds = number
  })
  default = {
    message_retention_seconds = 300
  }
}

variable "dlq_defaults" {
  description = "Default settings for the dead-letter queue (DLQ)"
  type = object({
    message_retention_seconds = number
    max_receive_count         = number
  })
  default = {
    message_retention_seconds = 86400
    max_receive_count         = 5
  }
}

# ----------------------------------------
# CloudWatch EventBridge Configuration
# ----------------------------------------

variable "eventbridge_rules" {
  description = "List of EventBridge rules that share the same SQS queue"
  type = list(object({
    name          = string
    description   = string
    event_pattern = string
    enable_rule   = optional(bool, true)
  }))
  default = []
}

# ----------------------------------------
# Slack Notification Configuration
# ----------------------------------------

variable "slack_webhook_url" {
  description = "Slack Webhook URL for sending notifications"
  type        = string
}

variable "message_title" {
  description = "Title of the message sent to Slack"
  type        = string
}

variable "message_fields" {
  description = "Comma-separated list of message fields"
  type        = string
}

variable "status_colors" {
  description = "Mapping of status to Slack colors"
  type        = string
}

variable "status_field" {
  description = "Field in the message that represents status"
  type        = string
}

variable "status_mapping" {
  description = "Mapping of status values to general categories"
  type        = string
}
