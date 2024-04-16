terraform {
  required_providers {
    aws = {
      version = "~> 5.45.0"
    }
  }
}

provider "aws" {
  region  = var.my_region
  profile = "sleonov-green"
}

resource "aws_instance" "my_instance" {
  ami           = var.my_instance_ami
  instance_type = var.my_instance_type
  subnet_id     = var.my_instance_subnet
  tags = {
    "Name" = "Howdy"
  }
}
