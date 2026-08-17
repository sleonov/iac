resource "aws_ssm_parameter" "instance_profile_name" {
  provider = aws.east
  name     = "/tf/aws-infra/iam/bastion/instance-profile-name"
  type     = "String"
  value    = aws_iam_instance_profile.bastion.name
}

resource "aws_ssm_parameter" "instance_profile_arn" {
  provider = aws.east
  name     = "/tf/aws-infra/iam/bastion/instance-profile-arn"
  type     = "String"
  value    = aws_iam_instance_profile.bastion.arn
}
