resource "aws_launch_template" "template" {
  description   = "My Launch Template"
  image_id      = var.instance_ami
  instance_type = "t2.micro"
  iam_instance_profile {
    name = "ec2-ssm-instance-profile"
  }
  user_data = filebase64("./scripts/user_data_web.sh")
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.lt_sg.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "Purpose" = "Instance for ${var.project_id}"
      "Name"    = "Autoscaling"
    }
  }
  tags = {
    "project-id" = var.project_id
  }
}