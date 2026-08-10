# East public route table
resource "aws_route_table" "east_public" {
  provider = aws.east
  vpc_id   = local.east_vpc_id
  tags = {
    Name = "rt-east-public"
    vpc  = "vpc-east-compute"
  }
}

# East private route table
resource "aws_route_table" "east_private" {
  provider = aws.east
  vpc_id   = local.east_vpc_id
  tags = {
    Name = "rt-east-private"
    vpc  = "vpc-east-compute"
  }
}

# East subnet associations
resource "aws_route_table_association" "east_public_a" {
  provider       = aws.east
  subnet_id      = local.east_public_subnet_a_id
  route_table_id = aws_route_table.east_public.id
}

resource "aws_route_table_association" "east_public_b" {
  provider       = aws.east
  subnet_id      = local.east_public_subnet_b_id
  route_table_id = aws_route_table.east_public.id
}

resource "aws_route_table_association" "east_private_a" {
  provider       = aws.east
  subnet_id      = local.east_private_subnet_a_id
  route_table_id = aws_route_table.east_private.id
}

resource "aws_route_table_association" "east_private_b" {
  provider       = aws.east
  subnet_id      = local.east_private_subnet_b_id
  route_table_id = aws_route_table.east_private.id
}

# West public route table
resource "aws_route_table" "west_public" {
  provider = aws.west
  vpc_id   = local.west_vpc_id
  tags = {
    Name = "rt-west-public"
    vpc  = "vpc-west-compute"
  }
}

# West private route table
resource "aws_route_table" "west_private" {
  provider = aws.west
  vpc_id   = local.west_vpc_id
  tags = {
    Name = "rt-west-private"
    vpc  = "vpc-west-compute"
  }
}

# West subnet associations
resource "aws_route_table_association" "west_public_a" {
  provider       = aws.west
  subnet_id      = local.west_public_subnet_a_id
  route_table_id = aws_route_table.west_public.id
}

resource "aws_route_table_association" "west_public_b" {
  provider       = aws.west
  subnet_id      = local.west_public_subnet_b_id
  route_table_id = aws_route_table.west_public.id
}

resource "aws_route_table_association" "west_private_a" {
  provider       = aws.west
  subnet_id      = local.west_private_subnet_a_id
  route_table_id = aws_route_table.west_private.id
}

resource "aws_route_table_association" "west_private_b" {
  provider       = aws.west
  subnet_id      = local.west_private_subnet_b_id
  route_table_id = aws_route_table.west_private.id
}
