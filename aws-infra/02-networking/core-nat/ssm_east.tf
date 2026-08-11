resource "aws_ssm_parameter" "nat_east_instance_id" {
  provider = aws.east
  name     = "/tf/aws-infra/networking/core-nat/instance-id"
  type     = "String"
  value    = aws_instance.nat_east.id
}
