resource "aws_vpc" "east" {
  provider             = aws.east
  cidr_block           = var.east_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    vpc-function = "compute"
  }
}

resource "aws_vpc" "west" {
  provider             = aws.west
  cidr_block           = var.west_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    vpc-function = "compute"
  }
}
