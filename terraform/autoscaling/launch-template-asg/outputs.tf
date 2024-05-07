output "lt_id" {
  value = aws_launch_template.template.id
}

output "asg_id" {
  value = aws_autoscaling_group.asg.id
}