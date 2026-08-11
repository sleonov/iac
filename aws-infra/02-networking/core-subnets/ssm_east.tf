resource "aws_ssm_parameter" "private_subnet_a_id" {
  provider = aws.east
  name     = "/tf/aws-infra/networking/core-subnets/private-subnet-a-id"
  type     = "String"
  value    = aws_subnet.east_private_a.id
}

resource "aws_ssm_parameter" "private_subnet_b_id" {
  provider = aws.east
  name     = "/tf/aws-infra/networking/core-subnets/private-subnet-b-id"
  type     = "String"
  value    = aws_subnet.east_private_b.id
}

resource "aws_ssm_parameter" "public_subnet_a_id" {
  provider = aws.east
  name     = "/tf/aws-infra/networking/core-subnets/public-subnet-a-id"
  type     = "String"
  value    = aws_subnet.east_public_a.id
}

resource "aws_ssm_parameter" "public_subnet_b_id" {
  provider = aws.east
  name     = "/tf/aws-infra/networking/core-subnets/public-subnet-b-id"
  type     = "String"
  value    = aws_subnet.east_public_b.id
}

resource "aws_ssm_parameter" "db_subnet_a_id" {
  provider = aws.east
  name     = "/tf/aws-infra/networking/core-subnets/db-subnet-a-id"
  type     = "String"
  value    = aws_subnet.east_db_a.id
}

resource "aws_ssm_parameter" "db_subnet_b_id" {
  provider = aws.east
  name     = "/tf/aws-infra/networking/core-subnets/db-subnet-b-id"
  type     = "String"
  value    = aws_subnet.east_db_b.id
}
