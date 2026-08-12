resource "aws_ssm_parameter" "public_zone_id_west" {
  provider = aws.west
  name     = "/tf/aws-infra/networking/core-dns/public-zone-id"
  type     = "String"
  value    = data.aws_route53_zone.public.zone_id
}

resource "aws_ssm_parameter" "public_zone_name_west" {
  provider = aws.west
  name     = "/tf/aws-infra/networking/core-dns/public-zone-name"
  type     = "String"
  value    = data.aws_route53_zone.public.name
}

resource "aws_ssm_parameter" "private_zone_id_west" {
  provider = aws.west
  name     = "/tf/aws-infra/networking/core-dns/private-zone-id"
  type     = "String"
  value    = aws_route53_zone.private_west.zone_id
}

resource "aws_ssm_parameter" "private_zone_name_west" {
  provider = aws.west
  name     = "/tf/aws-infra/networking/core-dns/private-zone-name"
  type     = "String"
  value    = aws_route53_zone.private_west.name
}
