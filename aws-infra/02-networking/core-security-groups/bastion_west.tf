resource "aws_security_group" "bastion_west" {
  provider    = aws.west
  name        = "bastion-west"
  description = "Bastion host security group"
  vpc_id      = local.west_vpc_id
  tags = {
    Name = "bastion-west"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_west_ssh" {
  provider          = aws.west
  security_group_id = aws_security_group.bastion_west.id
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.bastion_allowed_cidr
}

resource "aws_vpc_security_group_egress_rule" "bastion_west_all" {
  provider          = aws.west
  security_group_id = aws_security_group.bastion_west.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
