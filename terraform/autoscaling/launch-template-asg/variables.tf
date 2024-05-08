variable "project_id" {
  type    = string
  default = "Auto-scaling-group excercise"
}
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

variable "instance_profile" {
  type    = string
  default = "ec2-ssm-instance-profile"
}

variable "sg_names" {
  type    = list(string)
  default = ["http-https", "inbound-ssh"]
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 3
}

variable "asg_desired_size" {
  type    = number
  default = 2
}