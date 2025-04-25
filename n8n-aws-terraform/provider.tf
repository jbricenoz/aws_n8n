# provider.tf
# AWS provider configuration.

provider "aws" {
  region = var.aws_region

  # https://docs.aws.amazon.com/general/latest/gr/rande.html
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html
  # https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/SelectingRegion.html
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-application-load-balancer.html
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-management.html
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingBucket.html
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SettingUp.html
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html
  default_tags {
    tags = {
      Project     = "n8n-aws"
      Environment = var.environment
    }
  }
}

# Use the AWS provider version pinned in the module.
# This ensures proper operation in production.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}
