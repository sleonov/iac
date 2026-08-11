data "aws_ami" "fck_nat_west" {
  provider    = aws.west
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

resource "aws_instance" "nat_west" {
  provider             = aws.west
  ami                  = data.aws_ami.fck_nat_west.id
  instance_type        = var.nat_instance_type
  subnet_id            = local.west_public_subnet_a_id
  source_dest_check    = false
  iam_instance_profile = local.nat_instance_profile

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "stop"
      spot_instance_type             = "persistent"
    }
  }

  tags = {
    Name = "fck-nat-west"
  }
}

resource "aws_route" "west_private_to_nat" {
  provider               = aws.west
  route_table_id         = local.west_private_rt_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_west.primary_network_interface_id
}
