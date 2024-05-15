resource "aws_lb_target_group" "tg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.available_vpc.id
  health_check {
    protocol = "HTTP"
    path     = "/index.html"
    port     = 80
  }
}

resource "aws_lb" "lb" {
  name                       = "test-lb-tf"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = data.aws_security_groups.instance_sgs.ids
  subnets                    = data.aws_subnets.available_app_subnets.ids
  enable_deletion_protection = true
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}