# Requires core-subnets and core-routing to be applied first.
# Plan will fail if either module has not been applied yet.

data "terraform_remote_state" "core_subnets" {
  backend = "s3"
  config = {
    bucket = "terraform-state-607527010331"
    key    = "aws-infra/02-networking/core-subnets/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "core_routing" {
  backend = "s3"
  config = {
    bucket = "terraform-state-607527010331"
    key    = "aws-infra/02-networking/core-routing/terraform.tfstate"
    region = "us-east-1"
  }
}
