resource "aws_security_group" "bastion_east" {
  provider    = aws.east
  name        = "bastion-east"
  description = "Bastion host security group"
  vpc_id      = local.east_vpc_id
  tags = {
    Name = "bastion-east"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_east_ssh" {
  provider          = aws.east
  security_group_id = aws_security_group.bastion_east.id
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.bastion_allowed_cidr
}

resource "aws_vpc_security_group_egress_rule" "bastion_east_all" {
  provider          = aws.east
  security_group_id = aws_security_group.bastion_east.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
