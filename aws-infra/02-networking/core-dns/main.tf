data "aws_route53_zone" "public" {
  provider     = aws.east
  name         = var.public_zone_name
  private_zone = false
}

data "terraform_remote_state" "core_vpcs" {
  backend = "s3"
  config = {
    bucket = local.state_bucket
    key    = "aws-infra/02-networking/core-vpcs/terraform.tfstate"
    region = "us-east-1"
  }
}
