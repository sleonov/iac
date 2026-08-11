resource "aws_route53_record" "lb_friendly_dns" {
  name    = "${var.dns_short_name}.${var.dns_domain}"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.hz.id
  ttl     = "600"
  records = [aws_lb.lb.dns_name]
}