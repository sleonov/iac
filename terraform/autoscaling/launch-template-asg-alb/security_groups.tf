# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html

resource "aws_security_group" "lb_sg" {
  name   = "tf-load-balancer"
  vpc_id = data.aws_vpc.available_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow http from the world"
  }
  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = [data.aws_vpc.available_vpc.cidr_block]
    description     = "Health check and instance listener port"

  }
}

resource "aws_security_group" "lt_sg" {
  name   = "tf-launch-template"
  vpc_id = data.aws_vpc.available_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    description     = "Incoming http/healthcheck from Load balancer"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow http for yum installs"
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow https for yum installs"
  }
}
