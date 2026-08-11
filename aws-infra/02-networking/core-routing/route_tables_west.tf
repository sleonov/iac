resource "aws_route_table" "west_public" {
  provider = aws.west
  vpc_id   = local.west_vpc_id
  tags = {
    Name = "rt-west-public"
    vpc  = "vpc-west-compute"
  }
}

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

resource "aws_route_table" "west_private" {
  provider = aws.west
  vpc_id   = local.west_vpc_id
  tags = {
    Name = "rt-west-private"
    vpc  = "vpc-west-compute"
  }
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

# local routing only — no IGW, no peering
resource "aws_route_table" "west_db" {
  provider = aws.west
  vpc_id   = local.west_vpc_id
  tags = {
    Name = "rt-west-db"
    vpc  = "vpc-west-compute"
  }
}

resource "aws_route_table_association" "west_db_a" {
  provider       = aws.west
  subnet_id      = local.west_db_subnet_a_id
  route_table_id = aws_route_table.west_db.id
}

resource "aws_route_table_association" "west_db_b" {
  provider       = aws.west
  subnet_id      = local.west_db_subnet_b_id
  route_table_id = aws_route_table.west_db.id
}
