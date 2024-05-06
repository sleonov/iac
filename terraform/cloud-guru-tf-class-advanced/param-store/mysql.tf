resource "aws_db_instance" "default" {
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  username               = "foo"
  password               = aws_ssm_parameter.admin_password.value
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.allow_mysql_access.id]
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  subnet_ids = toset(data.aws_subnets.this.ids)
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["green-vpc-1"]
  }
}

# Public subnets so we can access the database
data "aws_subnets" "this" {
  filter {
    name   = "tag:Name"
    values = ["application-a", "application-b"]
  }
}

resource "aws_security_group" "allow_mysql_access" {
  name   = "allow_mysql_access"
  vpc_id = data.aws_vpc.this.id

  ingress {
    description = "Access MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_mysql_access"
  }
}