resource "aws_internet_gateway" "east" {
  provider = aws.east
  vpc_id   = local.east_vpc_id
  tags = {
    Name = "igw-east-compute"
    vpc  = "vpc-east-compute"
  }
}

resource "aws_route" "east_public_igw" {
  provider               = aws.east
  route_table_id         = aws_route_table.east_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.east.id
}
