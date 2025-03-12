
# module "ec2_auto_scaling_event" {
#   source = "../.."

#   region = data.aws_region.current.name
#   name   = "${local.name}-ec2-auto-scaling-event"
#   suffix = random_string.suffix.result

#   eventbridge_rules = [
#     {
#       name        = "ec2-auto-scaling-event"
#       description = "Capture EC2 Auto Scaling events"
#       event_pattern = jsonencode({
#         source = ["aws.autoscaling"]
#         "detail-type" = [
#           "EC2 Instance-launch Lifecycle Action",
#           "EC2 Instance-terminate Lifecycle Action",
#           "EC2 Instance Launch Successful",
#           "EC2 Instance Terminate Successful",
#           "EC2 Instance Launch Unsuccessful",
#           "EC2 Instance Terminate Unsuccessful",
#           "EC2 Auto Scaling Instance Refresh Checkpoint Reached",
#           "EC2 Auto Scaling Instance Refresh Started",
#           "EC2 Auto Scaling Instance Refresh Succeeded",
#           "EC2 Auto Scaling Instance Refresh Failed",
#           "EC2 Auto Scaling Instance Refresh Cancelled",
#           "EC2 Auto Scaling Instance Refresh Rollback Started",
#           "EC2 Auto Scaling Instance Refresh Rollback Succeeded",
#           "EC2 Auto Scaling Instance Refresh Rollback Failed"
#         ]
#       })
#     }
#   ]

#   slack_webhook_url = var.slack_webhook_url
#   message_title     = "EC2 Auto Scaling Event"
#   message_fields = join(",", [
#     "time",
#     "detail.eventName",
#     "detail.autoScalingGroupARN",
#     "detail.instanceId",
#     "detail.statusCode",
#     "detail.requestId",
#     "region"
#   ])
#   status_colors = join(",", [
#     "LAUNCHING:#2EB67D",
#     "TERMINATING:#E01E5A",
#     "SUCCESS:#36C5F0",
#     "FAILED:#FF5733",
#     "CANCELLED:#FFCC00"
#   ])
#   status_field = "detail.eventName"
#   status_mapping = join(",", [
#     "EC2 Instance-launch Lifecycle Action:LAUNCHING",
#     "EC2 Instance-terminate Lifecycle Action:TERMINATING",
#     "EC2 Instance Launch Successful:SUCCESS",
#     "EC2 Instance Terminate Successful:SUCCESS",
#     "EC2 Instance Launch Unsuccessful:FAILED",
#     "EC2 Instance Terminate Unsuccessful:FAILED",
#     "EC2 Auto Scaling Instance Refresh Checkpoint Reached:SUCCESS",
#     "EC2 Auto Scaling Instance Refresh Started:LAUNCHING",
#     "EC2 Auto Scaling Instance Refresh Succeeded:SUCCESS",
#     "EC2 Auto Scaling Instance Refresh Failed:FAILED",
#     "EC2 Auto Scaling Instance Refresh Cancelled:CANCELLED",
#     "EC2 Auto Scaling Instance Refresh Rollback Started:TERMINATING",
#     "EC2 Auto Scaling Instance Refresh Rollback Succeeded:SUCCESS",
#     "EC2 Auto Scaling Instance Refresh Rollback Failed:FAILED"
#   ])

#   log_retention_days = 1

#   tags = {
#     Environment = "dev"
#     Project     = "example-project"
#   }
# }
