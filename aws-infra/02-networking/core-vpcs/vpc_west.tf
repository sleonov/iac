resource "aws_vpc" "west" {
  provider             = aws.west
  cidr_block           = var.west_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name         = "vpc-west-compute"
    vpc-function = "compute"
  }
}
