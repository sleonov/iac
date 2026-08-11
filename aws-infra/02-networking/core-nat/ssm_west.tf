resource "aws_ssm_parameter" "nat_west_instance_id" {
  provider = aws.west
  name     = "/tf/aws-infra/networking/core-nat/instance-id"
  type     = "String"
  value    = aws_instance.nat_west.id
}
