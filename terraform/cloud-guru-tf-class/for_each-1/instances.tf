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

resource "aws_instance" "instances" {
  for_each      = toset(data.aws_subnets.available_app_subnets.ids)
  ami           = var.instance_ami
  subnet_id     = each.value
  instance_type = "t2.micro"
  tags = {
    "Name" = "instance-${index(data.aws_subnets.available_app_subnets.ids, each.value)}"
  }
}