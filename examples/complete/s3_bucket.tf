module "s3_public_access_events" {
  source = "../.."

  region = data.aws_region.current.name
  name   = "${local.name}-s3-public-access-events"
  suffix = random_string.suffix.result

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
    Environment = "dev"
    Project     = "example-project"
  }
}
