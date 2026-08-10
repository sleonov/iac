variable "east_region" {
  type    = string
  default = "us-east-1"
}

variable "west_region" {
  type    = string
  default = "us-west-1"
}

variable "bastion_allowed_cidr" {
  type        = string
  description = "CIDR allowed to SSH into bastion hosts"
}
