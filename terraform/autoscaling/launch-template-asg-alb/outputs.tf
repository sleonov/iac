output "lt_id" {
  value = aws_launch_template.template.id
}

output "asg_id" {
  value = aws_autoscaling_group.asg.id
}

output "tg_id" {
  value = aws_lb_target_group.tg.id
}

output "lb_dns_name" {
  value = aws_lb.lb.dns_name
}

output "lb_dns_friendly_name" {
  value = aws_route53_record.lb_friendly_dns.name
}