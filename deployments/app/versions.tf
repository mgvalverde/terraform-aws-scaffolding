terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.14.9"
  backend "s3" {
    encrypt        = true
    # Rest must be defined in environments/<environment>/<deployment>/backend.conf
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  tags = merge({
    "Own" : var.owner,
    "Prj" : var.project,
    "Env" : var.environment,
    "Terraform" : "true"
  }, var.extra_tags)

  account_id = data.aws_caller_identity.current.account_id
  region     = coalesce(var.region, data.aws_region.current.name)
  app_preffix   = "${var.owner}-${var.project}"
}
