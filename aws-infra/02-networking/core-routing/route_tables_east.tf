resource "aws_route_table" "east_public" {
  provider = aws.east
  vpc_id   = local.east_vpc_id
  tags = {
    Name = "rt-east-public"
    vpc  = "vpc-east-compute"
  }
}

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

resource "aws_route_table" "east_private" {
  provider = aws.east
  vpc_id   = local.east_vpc_id
  tags = {
    Name = "rt-east-private"
    vpc  = "vpc-east-compute"
  }
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

# local routing only — no IGW, no peering
resource "aws_route_table" "east_db" {
  provider = aws.east
  vpc_id   = local.east_vpc_id
  tags = {
    Name = "rt-east-db"
    vpc  = "vpc-east-compute"
  }
}

resource "aws_route_table_association" "east_db_a" {
  provider       = aws.east
  subnet_id      = local.east_db_subnet_a_id
  route_table_id = aws_route_table.east_db.id
}

resource "aws_route_table_association" "east_db_b" {
  provider       = aws.east
  subnet_id      = local.east_db_subnet_b_id
  route_table_id = aws_route_table.east_db.id
}
