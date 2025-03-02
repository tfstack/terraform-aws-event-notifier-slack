module "ecs_container_events" {
  source = "../.."

  region = data.aws_region.current.name
  name   = "${local.name}-ecs-container-events"
  suffix = random_string.suffix.result

  eventbridge_rules = [
    {
      name        = "ecs-container-events"
      description = "Capture ECS Container Instance State Change events"
      event_pattern = jsonencode({
        source        = ["aws.ecs"],
        "detail-type" = ["ECS Container Instance State Change"]
      })
      enable_rule = true
    }
  ]

  slack_webhook_url = var.slack_webhook_url
  message_title     = "ECS Container Instance Event"
  message_fields = join(",", [
    "time",
    "detail-type",
    "detail.containerInstanceArn",
    "detail.ec2InstanceId",
    "detail.status",
    "detail.agentConnected",
    "detail.versionInfo.agentVersion",
    "region"
  ])
  status_colors = join(",", [
    "ECS_INSTANCE_ACTIVE:#2EB67D",
    "ECS_INSTANCE_DEREGISTERED:#E01E5A",
    "ECS_AGENT_DISCONNECTED:#FFCC00"
  ])
  status_field = "detail.status"
  status_mapping = join(",", [
    "ACTIVE:ECS_INSTANCE_ACTIVE",
    "DEREGISTERING:ECS_INSTANCE_DEREGISTERED",
    "DEREGISTERED:ECS_INSTANCE_DEREGISTERED",
    "INACTIVE:ECS_INSTANCE_DEREGISTERED"
  ])

  log_retention_days = 1

  tags = {
    Environment = "dev"
    Project     = "example-project"
  }
}

module "ecs_task_events" {
  source = "../.."

  region = data.aws_region.current.name
  name   = "${local.name}-ecs-task-events"
  suffix = random_string.suffix.result

  eventbridge_rules = [
    {
      name        = "ecs-task-events"
      description = "Capture ECS Task State Change events"
      event_pattern = jsonencode({
        source        = ["aws.ecs"],
        "detail-type" = ["ECS Task State Change"]
      })
      enable_rule = true
    }
  ]

  slack_webhook_url = var.slack_webhook_url
  message_title     = "ECS Task State Change Event"
  message_fields = join(",", [
    "time",
    "detail-type",
    "detail.clusterArn",
    "detail.taskArn",
    "detail.lastStatus",
    "detail.desiredStatus",
    "detail.group",
    "detail.stopCode",
    "detail.stoppedReason",
    "detail.createdAt",
    "detail.startedAt",
    "detail.stoppedAt",
    "detail.pullStartedAt",
    "detail.pullStoppedAt",
    "detail.containers[].name",
    "detail.containers[].lastStatus",
    "detail.containers[].exitCode",
    "detail.containers[].reason",
    "region"
  ])
  status_colors = join(",", [
    "TASK_PENDING:#FFCC00",
    "TASK_RUNNING:#2EB67D",
    "TASK_STOPPED:#E01E5A",
    "TASK_FAILED:#FF5733",
    "TASK_PROVISIONING:#36C5F0",
    "TASK_DEACTIVATING:#FF9800"
  ])
  status_field = "detail.lastStatus"
  status_mapping = join(",", [
    "PROVISIONING:TASK_PROVISIONING",
    "PENDING:TASK_PENDING",
    "ACTIVATING:TASK_PROVISIONING",
    "RUNNING:TASK_RUNNING",
    "DEACTIVATING:TASK_DEACTIVATING",
    "DEPROVISIONING:TASK_DEACTIVATING",
    "STOPPED:TASK_STOPPED",
    "FAILED:TASK_FAILED"
  ])

  log_retention_days = 1

  tags = {
    Environment = "dev"
    Project     = "example-project"
  }
}

module "ecs_deployment_events" {
  source = "../.."

  region = data.aws_region.current.name
  name   = "${local.name}-ecs-deployment-events"
  suffix = random_string.suffix.result

  eventbridge_rules = [
    {
      name        = "ecs-deployment-events"
      description = "Capture ECS Deployment State Change events"
      event_pattern = jsonencode({
        source        = ["aws.ecs"],
        "detail-type" = ["ECS Deployment State Change"]
      })
      enable_rule = true
    }
  ]

  slack_webhook_url = var.slack_webhook_url
  message_title     = "ECS Deployment State Change Event"
  message_fields = join(",", [
    "time",
    "detail-type",
    "detail.clusterArn",
    "detail.serviceArn",
    "detail.deploymentId",
    "detail.deploymentStatus",
    "detail.rolloutState",
    "detail.updatedAt",
    "detail.taskSetId",
    "detail.reason",
    "region"
  ])
  status_colors = join(",", [
    "DEPLOYMENT_STARTED:#36C5F0",
    "DEPLOYMENT_IN_PROGRESS:#FFCC00",
    "DEPLOYMENT_COMPLETED:#2EB67D",
    "DEPLOYMENT_FAILED:#E01E5A",
    "DEPLOYMENT_ROLLBACK_IN_PROGRESS:#FF9800",
    "DEPLOYMENT_ROLLBACK_COMPLETED:#2EB67D",
    "DEPLOYMENT_ROLLBACK_FAILED:#FF5733"
  ])
  status_field = "detail.deploymentStatus"
  status_mapping = join(",", [
    "PRIMARY:DEPLOYMENT_STARTED",
    "IN_PROGRESS:DEPLOYMENT_IN_PROGRESS",
    "COMPLETED:DEPLOYMENT_COMPLETED",
    "FAILED:DEPLOYMENT_FAILED",
    "ROLLED_BACK:DEPLOYMENT_ROLLBACK_COMPLETED",
    "ROLLBACK_IN_PROGRESS:DEPLOYMENT_ROLLBACK_IN_PROGRESS",
    "ROLLBACK_FAILED:DEPLOYMENT_ROLLBACK_FAILED"
  ])

  log_retention_days = 1

  tags = {
    Environment = "dev"
    Project     = "example-project"
  }
}
