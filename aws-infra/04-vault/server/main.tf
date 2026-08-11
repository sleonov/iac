# Requires core-vpcs, core-subnets to be applied first.
# Plan will fail if either module has not been applied yet.

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "terraform_remote_state" "core_vpcs" {
  backend = "s3"
  config = {
    bucket = "terraform-state-607527010331"
    key    = "aws-infra/02-networking/core-vpcs/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "core_subnets" {
  backend = "s3"
  config = {
    bucket = "terraform-state-607527010331"
    key    = "aws-infra/02-networking/core-subnets/terraform.tfstate"
    region = "us-east-1"
  }
}
