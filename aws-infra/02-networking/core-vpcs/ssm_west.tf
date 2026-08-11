resource "aws_ssm_parameter" "vpc_id_west" {
  provider = aws.west
  name     = "/tf/aws-infra/core-vpcs/vpc-id"
  type     = "String"
  value    = aws_vpc.west.id
}

resource "aws_ssm_parameter" "vpc_cidr_west" {
  provider = aws.west
  name     = "/tf/aws-infra/core-vpcs/vpc-cidr"
  type     = "String"
  value    = aws_vpc.west.cidr_block
}
