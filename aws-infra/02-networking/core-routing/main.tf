data "terraform_remote_state" "core_subnets" {
  backend = "s3"
  config = {
    bucket = local.state_bucket
    key    = "aws-infra/02-networking/core-subnets/terraform.tfstate"
    region = "us-east-1"
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
