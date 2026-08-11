output "launch_template_id" {
  value = aws_launch_template.template.id
}

output "launch_template_security_group_id" {
  value = aws_security_group.lt_sg.id
}

output "autoscaling_group_id" {
  value = aws_autoscaling_group.asg.id
}

output "loadbalancer_target_group_id" {
  value = aws_lb_target_group.tg.id
}

output "loadbalancer_dns_name" {
  value = aws_lb.lb.dns_name
}

output "loadbalancer_security_group_id" {
  value = aws_security_group.lb_sg.id
}

output "loadbalancer_dns_friendly_name" {
  value = aws_route53_record.lb_friendly_dns.name
}