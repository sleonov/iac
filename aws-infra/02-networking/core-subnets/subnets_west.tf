resource "aws_subnet" "west_private_a" {
  provider                = aws.west
  vpc_id                  = local.west_vpc_id
  availability_zone       = local.west_az_a
  cidr_block              = local.west_private_az_a_cidr
  map_public_ip_on_launch = false
  tags = {
    Name        = "subnet-west-private-a"
    subnet-type = "private"
    az          = local.west_az_a
  }
}

resource "aws_subnet" "west_private_b" {
  provider                = aws.west
  vpc_id                  = local.west_vpc_id
  availability_zone       = local.west_az_b
  cidr_block              = local.west_private_az_b_cidr
  map_public_ip_on_launch = false
  tags = {
    Name        = "subnet-west-private-b"
    subnet-type = "private"
    az          = local.west_az_b
  }
}

resource "aws_subnet" "west_public_a" {
  provider                = aws.west
  vpc_id                  = local.west_vpc_id
  availability_zone       = local.west_az_a
  cidr_block              = local.west_public_az_a_cidr
  map_public_ip_on_launch = true
  tags = {
    Name        = "subnet-west-public-a"
    subnet-type = "public"
    az          = local.west_az_a
  }
}

resource "aws_subnet" "west_public_b" {
  provider                = aws.west
  vpc_id                  = local.west_vpc_id
  availability_zone       = local.west_az_b
  cidr_block              = local.west_public_az_b_cidr
  map_public_ip_on_launch = true
  tags = {
    Name        = "subnet-west-public-b"
    subnet-type = "public"
    az          = local.west_az_b
  }
}

resource "aws_subnet" "west_db_a" {
  provider                = aws.west
  vpc_id                  = local.west_vpc_id
  availability_zone       = local.west_az_a
  cidr_block              = local.west_db_az_a_cidr
  map_public_ip_on_launch = false
  tags = {
    Name        = "subnet-west-db-a"
    subnet-type = "db"
    az          = local.west_az_a
  }
}

resource "aws_subnet" "west_db_b" {
  provider                = aws.west
  vpc_id                  = local.west_vpc_id
  availability_zone       = local.west_az_b
  cidr_block              = local.west_db_az_b_cidr
  map_public_ip_on_launch = false
  tags = {
    Name        = "subnet-west-db-b"
    subnet-type = "db"
    az          = local.west_az_b
  }
}
