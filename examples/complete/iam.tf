# module "aws_root_login_events" {
#   source = "../.."

#   region = data.aws_region.current.region
#   name   = "${local.name}-aws-root-login-events"
#   suffix = random_string.suffix.result

#   eventbridge_rules = [
#     {
#       name        = "aws-root-login-detected"
#       description = "Detect root user login attempts"
#       event_pattern = jsonencode({
#         source        = ["aws.signin"],
#         "detail-type" = ["AWS Console Sign In via CloudTrail"],
#         detail = {
#           userIdentity = {
#             type = ["Root"]
#           }
#         }
#       })
#       enable_rule = true
#     }
#   ]

#   slack_webhook_url = var.slack_webhook_url
#   message_title     = "Root User Login Detected"
#   message_fields = join(",", [
#     "time",
#     "detail-type",
#     "detail.userIdentity.arn",
#     "detail.sourceIPAddress",
#     "detail.eventTime",
#     "detail.additionalEventData.MFAUsed",
#     "region"
#   ])
#   status_colors = join(",", [
#     "ROOT_LOGIN_DETECTED:#E01E5A",
#     "ROOT_LOGIN_WITH_MFA:#36C5F0"
#   ])
#   status_field = "detail.additionalEventData.MFAUsed"
#   status_mapping = join(",", [
#     "Yes:ROOT_LOGIN_WITH_MFA",
#     "No:ROOT_LOGIN_DETECTED"
#   ])

#   log_retention_days = 1

#   tags = {
#     Environment = "dev"
#     Project     = "example-project"
#   }
# }

# module "iam_policy_change_events" {
#   source = "../.."

#   region = data.aws_region.current.region
#   name   = "${local.name}-iam-policy-change-events"
#   suffix = random_string.suffix.result

#   eventbridge_rules = [
#     {
#       name        = "aws-iam-policy-change"
#       description = "Detect when IAM policies are changed"
#       event_pattern = jsonencode({
#         source        = ["aws.iam"],
#         "detail-type" = ["AWS API Call via CloudTrail"],
#         detail = {
#           eventSource = ["iam.amazonaws.com"],
#           eventName = [
#             "CreatePolicy",
#             "DeletePolicy",
#             "CreatePolicyVersion",
#             "DeletePolicyVersion",
#             "AttachRolePolicy",
#             "DetachRolePolicy",
#             "AttachUserPolicy",
#             "DetachUserPolicy",
#             "AttachGroupPolicy",
#             "DetachGroupPolicy",
#             "PutRolePolicy",
#             "DeleteRolePolicy",
#             "PutUserPolicy",
#             "DeleteUserPolicy",
#             "PutGroupPolicy",
#             "DeleteGroupPolicy"
#           ]
#         }
#       })
#       enable_rule = true
#     }
#   ]

#   slack_webhook_url = var.slack_webhook_url
#   message_title     = "IAM Policy Change Detected"
#   message_fields = join(",", [
#     "time",
#     "detail-type",
#     "detail.eventName",
#     "detail.userIdentity.arn",
#     "detail.sourceIPAddress",
#     "detail.requestParameters.policyArn",
#     "detail.requestParameters.policyName",
#     "region"
#   ])
#   status_colors = join(",", [
#     "POLICY_CREATED:#2EB67D",
#     "POLICY_DELETED:#E01E5A",
#     "POLICY_UPDATED:#FFCC00",
#     "POLICY_ATTACHED:#36C5F0",
#     "POLICY_DETACHED:#FF5733"
#   ])
#   status_field = "detail.eventName"
#   status_mapping = join(",", [
#     "CreatePolicy:POLICY_CREATED",
#     "DeletePolicy:POLICY_DELETED",
#     "CreatePolicyVersion:POLICY_UPDATED",
#     "DeletePolicyVersion:POLICY_UPDATED",
#     "AttachRolePolicy:POLICY_ATTACHED",
#     "DetachRolePolicy:POLICY_DETACHED",
#     "AttachUserPolicy:POLICY_ATTACHED",
#     "DetachUserPolicy:POLICY_DETACHED",
#     "AttachGroupPolicy:POLICY_ATTACHED",
#     "DetachGroupPolicy:POLICY_DETACHED",
#     "PutRolePolicy:POLICY_UPDATED",
#     "DeleteRolePolicy:POLICY_UPDATED",
#     "PutUserPolicy:POLICY_UPDATED",
#     "DeleteUserPolicy:POLICY_UPDATED",
#     "PutGroupPolicy:POLICY_UPDATED",
#     "DeleteGroupPolicy:POLICY_UPDATED"
#   ])

#   log_retention_days = 1

#   tags = {
#     Environment = "dev"
#     Project     = "example-project"
#   }
# }
