terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

variable "slack_webhook_url" {
  description = "Slack Webhook URL for sending notifications"
  type        = string
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  name = "demo"
}

# Uncommenting the below modules will create resources that can easily trigger test events.
# Ensure you need these resources before enabling them to avoid unnecessary costs.
# ⚠️ The S3 bucket is publicly accessible. Use with caution.

module "vpc" {
  source = "tfstack/vpc/aws"

  vpc_name           = local.name
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = data.aws_availability_zones.available.names

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  eic_subnet = "jumphost"

  jumphost_instance_create     = true
  jumphost_log_prevent_destroy = false
  jumphost_subnet              = "10.0.0.0/24"
  jumphost_allow_egress        = true

  create_igw = true
  ngw_type   = "single"
}

module "s3_bucket" {
  source = "tfstack/s3/aws"

  bucket_name         = local.name
  bucket_suffix       = random_string.suffix.result
  block_public_policy = false

  tags = {
    Environment = "dev"
    Project     = "example-project"
  }
}
