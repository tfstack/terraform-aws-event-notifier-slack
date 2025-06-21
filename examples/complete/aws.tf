# module "aws_support_case_events" {
#   source = "../.."

#   region = data.aws_region.current.region
#   name   = "${local.name}-aws-support-case-events"
#   suffix = random_string.suffix.result

#   eventbridge_rules = [
#     {
#       name        = "aws-support-case-events"
#       description = "Detect AWS Support case activity"
#       event_pattern = jsonencode({
#         source = ["aws.support"],
#         "detail-type" = [
#           "Support Case Created",
#           "Support Case Resolved",
#           "Support Case Reopened",
#           "Support Case Assigned",
#           "Support Case Updated"
#         ]
#       })
#       enable_rule = true
#     }
#   ]

#   slack_webhook_url = var.slack_webhook_url
#   message_title     = "AWS Support Case Event"
#   message_fields = join(",", [
#     "time",
#     "detail-type",
#     "detail.caseId",
#     "detail.displayId",
#     "detail.subject",
#     "detail.severityCode",
#     "detail.categoryCode",
#     "detail.serviceCode",
#     "detail.status",
#     "region"
#   ])
#   status_colors = join(",", [
#     "CASE_CREATED:#2EB67D",
#     "CASE_RESOLVED:#36C5F0",
#     "CASE_REOPENED:#FFCC00",
#     "CASE_ASSIGNED:#FF9800",
#     "CASE_UPDATED:#FFC107"
#   ])
#   status_field = "detail-type"
#   status_mapping = join(",", [
#     "Support Case Created:CASE_CREATED",
#     "Support Case Resolved:CASE_RESOLVED",
#     "Support Case Reopened:CASE_REOPENED",
#     "Support Case Assigned:CASE_ASSIGNED",
#     "Support Case Updated:CASE_UPDATED"
#   ])

#   log_retention_days = 1

#   tags = {
#     Environment = "dev"
#     Project     = "example-project"
#   }
# }

# module "aws_health_event" {
#   source = "../.."

#   region = data.aws_region.current.region
#   name   = "${local.name}-aws-health-event"
#   suffix = random_string.suffix.result

#   eventbridge_rules = [
#     {
#       name        = "aws-health-event"
#       description = "Detect AWS Health events affecting services"
#       event_pattern = jsonencode({
#         source        = ["aws.health"],
#         "detail-type" = ["AWS Health Event"]
#       })
#       enable_rule = true
#     }
#   ]

#   slack_webhook_url = var.slack_webhook_url
#   message_title     = "AWS Health Event"
#   message_fields = join(",", [
#     "time",
#     "detail-type",
#     "detail.eventArn",
#     "detail.service",
#     "detail.eventTypeCategory",
#     "detail.eventTypeCode",
#     "detail.region"
#   ])
#   status_colors = join(",", [
#     "ISSUE:#FF0000",
#     "SCHEDULED_CHANGE:#FFA500",
#     "ACCOUNT_NOTIFICATION:#00FF00"
#   ])
#   status_field = "detail.eventTypeCategory"
#   status_mapping = join(",", [
#     "issue:ISSUE",
#     "scheduledChange:SCHEDULED_CHANGE",
#     "accountNotification:ACCOUNT_NOTIFICATION"
#   ])

#   log_retention_days = 1

#   tags = {
#     Environment = "dev"
#     Project     = "example-project"
#   }
# }
