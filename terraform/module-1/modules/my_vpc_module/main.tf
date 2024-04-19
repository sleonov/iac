provider "aws" {
  region  = var.region
  profile = "sleonov-green"
}

resource "aws_vpc" "vpc_cidr" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc_cidr.id
  cidr_block = "10.0.1.0/24"
}

data "aws_ssm_parameter" "amazon_ami_id" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
