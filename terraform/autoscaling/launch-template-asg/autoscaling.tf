data "aws_vpc" "available_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "available_app_subnets" {
  filter {
    name   = "tag:Name"
    values = ["*${var.subnets_name_pattern}*"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.available_vpc.id]
  }
}

data "aws_security_groups" "instance_sgs" {
  filter {
    name   = "group-name"
    values = var.sg_names
  }
}

resource "aws_launch_template" "template" {
  description   = "My Launch Template"
  image_id      = var.instance_ami
  instance_type = "t2.micro"
  iam_instance_profile {
    name = "ec2-ssm-instance-profile"
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
    }
  }
  user_data = filebase64("./scripts/user_data_web.sh")
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = data.aws_security_groups.instance_sgs.ids
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "Purpose" = "Instance for ${var.project_id}"
    }
  }
  tags = {
    "project-id" = var.project_id
  }
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = data.aws_subnets.available_app_subnets.ids
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_size
  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "target_tracking" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  cooldown               = 0
  enabled                = true
  name                   = "target-tracking-1"
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