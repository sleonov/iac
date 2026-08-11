data "terraform_remote_state" "core_vpcs" {
  backend = "s3"
  config = {
    bucket = "terraform-state-607527010331"
    key    = "aws-infra/02-networking/core-vpcs/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_availability_zones" "east" {
  provider = aws.east
  state    = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

data "aws_availability_zones" "west" {
  provider = aws.west
  state    = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}
