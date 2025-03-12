# module "aws_vpc_event" {
#   source = "../.."

#   region = data.aws_region.current.name
#   name   = "${local.name}-aws-vpc-event"
#   suffix = random_string.suffix.result

#   eventbridge_rules = [
#     {
#       name        = "aws-vpc-event"
#       description = "Detect AWS VPC related events"
#       event_pattern = jsonencode({
#         source        = ["aws.ec2"],
#         "detail-type" = ["AWS API Call via CloudTrail"],
#         detail = {
#           eventSource = ["ec2.amazonaws.com"],
#           eventName = [
#             "CreateVpc",
#             "ModifyVpcAttribute",
#             "DeleteVpc",
#             "CreateSubnet",
#             "ModifySubnetAttribute",
#             "DeleteSubnet",
#             "CreateRouteTable",
#             "ReplaceRouteTableAssociation",
#             "DeleteRouteTable",
#             "CreateRoute",
#             "ReplaceRoute",
#             "DeleteRoute",
#             "CreateVpcEndpoint",
#             "DeleteVpcEndpoints",
#             "CreateVpcPeeringConnection",
#             "DeleteVpcPeeringConnection",
#             "AcceptVpcPeeringConnection",
#             "RejectVpcPeeringConnection"
#           ]
#         }
#       })
#       enable_rule = true
#     }
#   ]

#   slack_webhook_url = var.slack_webhook_url
#   message_title     = "AWS VPC Event"
#   message_fields = join(",", [
#     "time",
#     "detail.eventSource",
#     "detail.eventName",
#     "detail.requestParameters.vpcId",
#     "detail.requestParameters.subnetId",
#     "detail.requestParameters.routeTableId",
#     "detail.awsRegion"
#   ])
#   status_colors = join(",", [
#     "CreateVpc:#2EB67D",
#     "ModifyVpcAttribute:#FFC107",
#     "DeleteVpc:#FF0000",
#     "CreateSubnet:#2EB67D",
#     "ModifySubnetAttribute:#FFC107",
#     "DeleteSubnet:#FF0000",
#     "CreateRouteTable:#2EB67D",
#     "ReplaceRouteTableAssociation:#FFC107",
#     "DeleteRouteTable:#FF0000",
#     "CreateRoute:#2EB67D",
#     "ReplaceRoute:#FFC107",
#     "DeleteRoute:#FF0000",
#     "CreateVpcEndpoint:#2EB67D",
#     "DeleteVpcEndpoints:#FF0000",
#     "CreateVpcPeeringConnection:#2EB67D",
#     "DeleteVpcPeeringConnection:#FF0000",
#     "AcceptVpcPeeringConnection:#2EB67D",
#     "RejectVpcPeeringConnection:#FF0000"
#   ])
#   status_field = "detail.eventName"
#   status_mapping = join(",", [
#     "CreateVpc:CreateVpc",
#     "ModifyVpcAttribute:ModifyVpcAttribute",
#     "DeleteVpc:DeleteVpc",
#     "CreateSubnet:CreateSubnet",
#     "ModifySubnetAttribute:ModifySubnetAttribute",
#     "DeleteSubnet:DeleteSubnet",
#     "CreateRouteTable:CreateRouteTable",
#     "ReplaceRouteTableAssociation:ReplaceRouteTableAssociation",
#     "DeleteRouteTable:DeleteRouteTable",
#     "CreateRoute:CreateRoute",
#     "ReplaceRoute:ReplaceRoute",
#     "DeleteRoute:DeleteRoute",
#     "CreateVpcEndpoint:CreateVpcEndpoint",
#     "DeleteVpcEndpoints:DeleteVpcEndpoints",
#     "CreateVpcPeeringConnection:CreateVpcPeeringConnection",
#     "DeleteVpcPeeringConnection:DeleteVpcPeeringConnection",
#     "AcceptVpcPeeringConnection:AcceptVpcPeeringConnection",
#     "RejectVpcPeeringConnection:RejectVpcPeeringConnection"
#   ])

#   log_retention_days = 1

#   tags = {
#     Environment = "dev"
#     Project     = "example-project"
#   }
# }
