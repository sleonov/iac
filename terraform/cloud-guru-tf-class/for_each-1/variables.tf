variable "subnets_name_pattern" {
  type    = string
  default = "application"
}

variable "vpc_name" {
  type    = string
  default = "green-vpc-1"
}

variable "instance_ami" {
  type    = string
  default = "ami-051f8a213df8bc089"
}