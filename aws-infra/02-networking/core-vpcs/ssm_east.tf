resource "aws_ssm_parameter" "vpc_id" {
  provider = aws.east
  name     = "/tf/aws-infra/core-vpcs/vpc-id"
  type     = "String"
  value    = aws_vpc.east.id
}

resource "aws_ssm_parameter" "vpc_cidr" {
  provider = aws.east
  name     = "/tf/aws-infra/core-vpcs/vpc-cidr"
  type     = "String"
  value    = aws_vpc.east.cidr_block
}
