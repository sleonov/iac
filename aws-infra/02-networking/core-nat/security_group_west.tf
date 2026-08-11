resource "aws_security_group" "nat_west" {
  provider    = aws.west
  name        = "nat-west"
  description = "NAT instance - allows inbound from both VPCs for traffic forwarding"
  vpc_id      = local.west_vpc_id
}

# Allow all inbound from west VPC — NAT must accept forwarded traffic from private subnets
resource "aws_vpc_security_group_ingress_rule" "nat_west_from_west_vpc" {
  provider          = aws.west
  security_group_id = aws_security_group.nat_west.id
  ip_protocol       = "-1"
  cidr_ipv4         = local.west_vpc_cidr
}

# Allow all inbound from east VPC — peered traffic may also route through west NAT
resource "aws_vpc_security_group_ingress_rule" "nat_west_from_east_vpc" {
  provider          = aws.west
  security_group_id = aws_security_group.nat_west.id
  ip_protocol       = "-1"
  cidr_ipv4         = local.east_vpc_cidr
}

# Allow all outbound — NAT forwards packets to the internet on behalf of private subnet instances
resource "aws_vpc_security_group_egress_rule" "nat_west_all" {
  provider          = aws.west
  security_group_id = aws_security_group.nat_west.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
