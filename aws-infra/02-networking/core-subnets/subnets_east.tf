resource "aws_subnet" "east_private_a" {
  provider                = aws.east
  vpc_id                  = local.east_vpc_id
  availability_zone       = local.east_az_a
  cidr_block              = local.east_private_az_a_cidr
  map_public_ip_on_launch = false
  tags = {
    Name        = "subnet-east-private-a"
    subnet-type = "private"
    az          = local.east_az_a
  }
}

resource "aws_subnet" "east_private_b" {
  provider                = aws.east
  vpc_id                  = local.east_vpc_id
  availability_zone       = local.east_az_b
  cidr_block              = local.east_private_az_b_cidr
  map_public_ip_on_launch = false
  tags = {
    Name        = "subnet-east-private-b"
    subnet-type = "private"
    az          = local.east_az_b
  }
}

resource "aws_subnet" "east_public_a" {
  provider                = aws.east
  vpc_id                  = local.east_vpc_id
  availability_zone       = local.east_az_a
  cidr_block              = local.east_public_az_a_cidr
  map_public_ip_on_launch = true
  tags = {
    Name        = "subnet-east-public-a"
    subnet-type = "public"
    az          = local.east_az_a
  }
}

resource "aws_subnet" "east_public_b" {
  provider                = aws.east
  vpc_id                  = local.east_vpc_id
  availability_zone       = local.east_az_b
  cidr_block              = local.east_public_az_b_cidr
  map_public_ip_on_launch = true
  tags = {
    Name        = "subnet-east-public-b"
    subnet-type = "public"
    az          = local.east_az_b
  }
}

resource "aws_subnet" "east_db_a" {
  provider                = aws.east
  vpc_id                  = local.east_vpc_id
  availability_zone       = local.east_az_a
  cidr_block              = local.east_db_az_a_cidr
  map_public_ip_on_launch = false
  tags = {
    Name        = "subnet-east-db-a"
    subnet-type = "db"
    az          = local.east_az_a
  }
}

resource "aws_subnet" "east_db_b" {
  provider                = aws.east
  vpc_id                  = local.east_vpc_id
  availability_zone       = local.east_az_b
  cidr_block              = local.east_db_az_b_cidr
  map_public_ip_on_launch = false
  tags = {
    Name        = "subnet-east-db-b"
    subnet-type = "db"
    az          = local.east_az_b
  }
}
