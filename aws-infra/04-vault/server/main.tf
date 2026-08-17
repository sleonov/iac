# Requires core-vpcs, core-subnets to be applied first.
# Plan will fail if either module has not been applied yet.
# core-nat must also be running before apply: Vault's startup script reaches KMS (auto-unseal),
# S3 (storage), and Secrets Manager (init output) over the internet via NAT. Without outbound
# access the instance will boot but Vault will fail to unseal and the init script will stall.

data "aws_caller_identity" "current" {
  provider = aws.east
}

data "aws_ami" "amazon_linux_2023" {
  provider    = aws.east
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
    bucket = local.state_bucket
    key    = "aws-infra/02-networking/core-vpcs/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "core_subnets" {
  backend = "s3"
  config = {
    bucket = local.state_bucket
    key    = "aws-infra/02-networking/core-subnets/terraform.tfstate"
    region = "us-east-1"
  }
}
