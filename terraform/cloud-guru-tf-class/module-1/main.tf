provider "aws" {
  profile = "sleonov-green"
  region  = var.instance_region
}

module "my_vpc_module" {
  source = "./modules/my_vpc_module"
  region = var.instance_region
}

resource "aws_instance" "my-instance" {
  ami           = module.my_vpc_module.ami_id
  subnet_id     = module.my_vpc_module.subnet_id
  instance_type = "t2.micro"
}
