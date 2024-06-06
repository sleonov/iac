resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = data.aws_subnets.available_app_subnets.ids
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_size
  warm_pool {
    min_size   = var.warm_pool_min_size
    pool_state = "Running"
  }
  health_check_type = "ELB"
  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.tg.id]
}

resource "aws_autoscaling_policy" "target_tracking" {
  name                   = "target-tracking-1"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  cooldown               = 0
  enabled                = true
  policy_type            = "TargetTrackingScaling"
  scaling_adjustment     = 0
  target_tracking_configuration {
    disable_scale_in = false
    target_value     = 50
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

resource "aws_autoscaling_schedule" "schedule_1" {
  scheduled_action_name  = "shrink"
  min_size               = 0
  max_size               = 1
  desired_capacity       = 0
  start_time             = "2025-12-11T18:00:00Z"
  end_time               = "2025-12-12T06:00:00Z"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}