output "east_private_subnets" {
  value = {
    az_a = {
      id     = aws_subnet.east_private_a.id
      az     = aws_subnet.east_private_a.availability_zone
      cidr   = aws_subnet.east_private_a.cidr_block
      vpc_id = aws_subnet.east_private_a.vpc_id
    }
    az_b = {
      id     = aws_subnet.east_private_b.id
      az     = aws_subnet.east_private_b.availability_zone
      cidr   = aws_subnet.east_private_b.cidr_block
      vpc_id = aws_subnet.east_private_b.vpc_id
    }
  }
}

output "east_public_subnets" {
  value = {
    az_a = {
      id     = aws_subnet.east_public_a.id
      az     = aws_subnet.east_public_a.availability_zone
      cidr   = aws_subnet.east_public_a.cidr_block
      vpc_id = aws_subnet.east_public_a.vpc_id
    }
    az_b = {
      id     = aws_subnet.east_public_b.id
      az     = aws_subnet.east_public_b.availability_zone
      cidr   = aws_subnet.east_public_b.cidr_block
      vpc_id = aws_subnet.east_public_b.vpc_id
    }
  }
}

output "east_db_subnets" {
  value = {
    az_a = {
      id     = aws_subnet.east_db_a.id
      az     = aws_subnet.east_db_a.availability_zone
      cidr   = aws_subnet.east_db_a.cidr_block
      vpc_id = aws_subnet.east_db_a.vpc_id
    }
    az_b = {
      id     = aws_subnet.east_db_b.id
      az     = aws_subnet.east_db_b.availability_zone
      cidr   = aws_subnet.east_db_b.cidr_block
      vpc_id = aws_subnet.east_db_b.vpc_id
    }
  }
}

output "west_private_subnets" {
  value = {
    az_a = {
      id     = aws_subnet.west_private_a.id
      az     = aws_subnet.west_private_a.availability_zone
      cidr   = aws_subnet.west_private_a.cidr_block
      vpc_id = aws_subnet.west_private_a.vpc_id
    }
    az_b = {
      id     = aws_subnet.west_private_b.id
      az     = aws_subnet.west_private_b.availability_zone
      cidr   = aws_subnet.west_private_b.cidr_block
      vpc_id = aws_subnet.west_private_b.vpc_id
    }
  }
}

output "west_public_subnets" {
  value = {
    az_a = {
      id     = aws_subnet.west_public_a.id
      az     = aws_subnet.west_public_a.availability_zone
      cidr   = aws_subnet.west_public_a.cidr_block
      vpc_id = aws_subnet.west_public_a.vpc_id
    }
    az_b = {
      id     = aws_subnet.west_public_b.id
      az     = aws_subnet.west_public_b.availability_zone
      cidr   = aws_subnet.west_public_b.cidr_block
      vpc_id = aws_subnet.west_public_b.vpc_id
    }
  }
}

output "west_db_subnets" {
  value = {
    az_a = {
      id     = aws_subnet.west_db_a.id
      az     = aws_subnet.west_db_a.availability_zone
      cidr   = aws_subnet.west_db_a.cidr_block
      vpc_id = aws_subnet.west_db_a.vpc_id
    }
    az_b = {
      id     = aws_subnet.west_db_b.id
      az     = aws_subnet.west_db_b.availability_zone
      cidr   = aws_subnet.west_db_b.cidr_block
      vpc_id = aws_subnet.west_db_b.vpc_id
    }
  }
}
