# East region: IGW and default public route
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

# West region: IGW and default public route
resource "aws_internet_gateway" "west" {
  provider = aws.west
  vpc_id   = local.west_vpc_id
  tags = {
    Name = "igw-west-compute"
    vpc  = "vpc-west-compute"
  }
}

resource "aws_route" "west_public_igw" {
  provider               = aws.west
  route_table_id         = aws_route_table.west_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.west.id
}
