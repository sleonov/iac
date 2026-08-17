data "aws_ami" "fck_nat_east" {
  provider    = aws.east
  most_recent = true
  owners      = ["568608671756"]

  filter {
    name   = "name"
    values = ["fck-nat-al2023-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_instance" "nat_east" {
  provider               = aws.east
  ami                    = data.aws_ami.fck_nat_east.id
  instance_type          = var.nat_instance_type
  subnet_id              = local.east_public_subnet_a_id
  source_dest_check      = false
  iam_instance_profile   = local.nat_instance_profile
  vpc_security_group_ids = [aws_security_group.nat_east.id]

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "stop"
      spot_instance_type             = "persistent"
    }
  }

  tags = {
    Name              = "fck-nat-east"
    manage-r53-record = ""
  }
}

resource "aws_route" "east_private_to_nat" {
  provider               = aws.east
  route_table_id         = local.east_private_rt_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_east.primary_network_interface_id
}
