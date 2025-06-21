module "ec2_state_change" {
  source = "../.."

  region = data.aws_region.current.region
  name   = "${local.name}-ec2-state-change"
  suffix = random_string.suffix.result

  eventbridge_rules = [
    {
      name        = "ec2-state-change"
      description = "Capture EC2 instance state changes"
      event_pattern = jsonencode({
        source        = ["aws.ec2"]
        "detail-type" = ["EC2 Instance State-change Notification"]
        detail = {
          state         = ["pending", "running", "shutting-down", "stopping", "stopped", "terminated"]
          "instance-id" = [module.vpc.jumphost_instance_id]
        }
      })
    }
  ]

  slack_webhook_url = var.slack_webhook_url
  message_title     = "EC2 State Change"
  message_fields    = "time,detail.instance-id,detail.state,region"
  status_colors     = "UP:#2EB67D,WARN:#FFCC00,DOWN:#E01E5A,UNKNOWN:#CCCCCC"
  status_field      = "detail.state"
  status_mapping = join(",", [
    "pending:WARN",
    "running:UP",
    "shutting-down:WARN",
    "stopping:WARN",
    "stopped:DOWN",
    "terminated:DOWN"
  ])

  log_retention_days = 1

  tags = {
    Environment = "dev"
    Project     = "example-project"
  }
}

# module "ec2_sg_change" {
#   source = "../.."

#   region = data.aws_region.current.region
#   name   = "${local.name}-ec2-sg-change"
#   suffix = random_string.suffix.result

#   eventbridge_rules = [
#     {
#       name        = "ec2-sg-change"
#       description = "Detect changes to security group rules"
#       event_pattern = jsonencode({
#         source        = ["aws.ec2"]
#         "detail-type" = ["AWS API Call via CloudTrail"]
#         detail = {
#           eventSource = ["ec2.amazonaws.com"]
#           eventName = [
#             "AuthorizeSecurityGroupIngress",
#             "CreateSecurityGroup",
#             "DeleteSecurityGroup",
#             "ModifySecurityGroupRules",
#             "RevokeSecurityGroupIngress"
#           ]
#         }
#       })
#       enable_rule = true
#     }
#   ]

#   slack_webhook_url = var.slack_webhook_url
#   message_title     = "EC2 Security Group Change"
#   message_fields    = "time,detail.eventName,detail.requestParameters.groupId,detail.requestParameters.ipPermissions,region"
#   status_colors     = "ADDED:#2EB67D,REMOVED:#E01E5A,CREATED:#36C5F0,DELETED:#FF5733,MODIFIED:#FFCC00"
#   status_field      = "detail.eventName"
#   status_mapping = join(",", [
#     "AuthorizeSecurityGroupIngress:ADDED",
#     "RevokeSecurityGroupIngress:REMOVED",
#     "CreateSecurityGroup:CREATED",
#     "DeleteSecurityGroup:DELETED",
#     "ModifySecurityGroupRules:MODIFIED"
#   ])

#   log_retention_days = 1

#   tags = {
#     Environment = "dev"
#     Project     = "example-project"
#   }
# }

# module "ec2_eip_activity" {
#   source = "../.."

#   region = data.aws_region.current.region
#   name   = "${local.name}-ec2-eip-activity"
#   suffix = random_string.suffix.result

#   eventbridge_rules = [
#     {
#       name        = "ec2-eip-activity"
#       description = "Detect Elastic IP allocation, release, attachment, and detachment activities"
#       event_pattern = jsonencode({
#         source        = ["aws.ec2"]
#         "detail-type" = ["AWS API Call via CloudTrail"]
#         detail = {
#           eventSource = ["ec2.amazonaws.com"]
#           eventName = [
#             "AllocateAddress",
#             "ReleaseAddress",
#             "AssociateAddress",
#             "DisassociateAddress"
#           ]
#         }
#       })
#       enable_rule = true
#     }
#   ]

#   slack_webhook_url = var.slack_webhook_url
#   message_title     = "EC2 Elastic IP Activity"
#   message_fields = join(",", [
#     "time",
#     "detail.eventName",
#     "detail.userIdentity.arn",
#     "detail.requestParameters.allocationId",
#     "detail.requestParameters.associationId",
#     "detail.requestParameters.publicIp",
#     "detail.requestParameters.instanceId",
#     "region"
#   ])
#   status_colors = join(",", [
#     "ALLOCATED:#2EB67D",
#     "RELEASED:#E01E5A",
#     "ATTACHED:#36C5F0",
#     "DETACHED:#FF5733"
#   ])
#   status_field = "detail.eventName"
#   status_mapping = join(",", [
#     "AllocateAddress:ALLOCATED",
#     "ReleaseAddress:RELEASED",
#     "AssociateAddress:ATTACHED",
#     "DisassociateAddress:DETACHED"
#   ])

#   log_retention_days = 1

#   tags = {
#     Environment = "dev"
#     Project     = "example-project"
#   }
# }

# module "ec2_spot_instance_events" {
#   source = "../.."

#   region = data.aws_region.current.region
#   name   = "${local.name}-ec2-spot-instance-events"
#   suffix = random_string.suffix.result

#   eventbridge_rules = [
#     {
#       name        = "ec2-spot-instance-events"
#       description = "Capture EC2 Spot Instance events"
#       event_pattern = jsonencode({
#         source = ["aws.ec2"],
#         "detail-type" = [
#           "EC2 Spot Instance Interruption Warning",
#           "EC2 Instance Rebalance Recommendation"
#         ]
#       })
#       enable_rule = true
#     }
#   ]

#   slack_webhook_url = var.slack_webhook_url
#   message_title     = "EC2 Spot Instance Event"
#   message_fields = join(",", [
#     "time",
#     "detail-type",
#     "detail.instance-id",
#     "detail.instance-action",
#     "region"
#   ])
#   status_colors = join(",", [
#     "INTERRUPTION_WARNING:#FFCC00",
#     "REBALANCE_RECOMMENDATION:#36C5F0"
#   ])
#   status_field = "detail-type"
#   status_mapping = join(",", [
#     "EC2 Spot Instance Interruption Warning:INTERRUPTION_WARNING",
#     "EC2 Instance Rebalance Recommendation:REBALANCE_RECOMMENDATION"
#   ])

#   log_retention_days = 1

#   tags = {
#     Environment = "dev"
#     Project     = "example-project"
#   }
# }
