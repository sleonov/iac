data "aws_vpc" "available_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "available_app_subnets" {
  filter {
    name   = "tag:Name"
    values = ["*${var.subnets_name_pattern}*"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.available_vpc.id]
  }
}

data "aws_security_groups" "instance_sgs" {
  filter {
    name   = "group-name"
    values = var.sg_names
  }
}

data "aws_route53_zone" "hz" {
  name = var.dns_domain
}