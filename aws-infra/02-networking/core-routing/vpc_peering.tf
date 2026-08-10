# VPC peering between east (us-east-1) and west (us-west-1) regions.
# Requester: east side initiates the connection (auto_accept must be false for cross-region peering).
# Accepter: west side accepts automatically via Terraform (auto_accept = true).
# Routes are added to both public and private route tables in each region.

# VPC peering between east and west regions — requester side
resource "aws_vpc_peering_connection" "east_to_west" {
  provider    = aws.east
  vpc_id      = local.east_vpc_id
  peer_vpc_id = local.west_vpc_id
  peer_region = var.west_region
  auto_accept = false
  tags = {
    Name = "pcx-east-to-west"
  }
}

# Accepter side — must use the west provider
resource "aws_vpc_peering_connection_accepter" "west" {
  provider                  = aws.west
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
  auto_accept               = true
  tags = {
    Name = "pcx-east-to-west"
  }
}

# Routes from east to west via peering
resource "aws_route" "east_public_to_west" {
  provider                  = aws.east
  route_table_id            = aws_route_table.east_public.id
  destination_cidr_block    = local.west_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
}

resource "aws_route" "east_private_to_west" {
  provider                  = aws.east
  route_table_id            = aws_route_table.east_private.id
  destination_cidr_block    = local.west_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
}

# Routes from west to east via peering
resource "aws_route" "west_public_to_east" {
  provider                  = aws.west
  route_table_id            = aws_route_table.west_public.id
  destination_cidr_block    = local.east_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
}

resource "aws_route" "west_private_to_east" {
  provider                  = aws.west
  route_table_id            = aws_route_table.west_private.id
  destination_cidr_block    = local.east_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
}
