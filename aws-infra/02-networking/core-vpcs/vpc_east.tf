resource "aws_vpc" "east" {
  provider             = aws.east
  cidr_block           = var.east_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name         = "vpc-east-compute"
    vpc-function = "compute"
  }
}
