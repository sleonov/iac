output "public_zone_id" {
  value = data.aws_route53_zone.public.zone_id
}

output "public_zone_name" {
  value = data.aws_route53_zone.public.name
}

output "east_private_zone_id" {
  value = aws_route53_zone.private_east.zone_id
}

output "east_private_zone_name" {
  value = aws_route53_zone.private_east.name
}

output "west_private_zone_id" {
  value = aws_route53_zone.private_west.zone_id
}

output "west_private_zone_name" {
  value = aws_route53_zone.private_west.name
}
