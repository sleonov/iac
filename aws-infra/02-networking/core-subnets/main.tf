data "terraform_remote_state" "core_vpcs" {
  backend = "s3"
  config = {
    bucket = "terraform-state-607527010331"
    key    = "aws-infra/02-networking/core-vpcs/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_availability_zones" "east" {
  provider = aws.east
  state    = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

data "aws_availability_zones" "west" {
  provider = aws.west
  state    = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

# East region: 2 private, 2 public 2 db subnets
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

# West region: 2 private, 2 public, 2 db subnets
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
