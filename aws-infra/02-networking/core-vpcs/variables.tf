variable "east_region" {
  type    = string
  default = "us-east-1"
}

variable "west_region" {
  type    = string
  default = "us-west-1"
}

variable "east_vpc_cidr" {
  type        = string
  description = "Primary CIDR"
  default     = "10.1.0.0/16"
}

variable "west_vpc_cidr" {
  type        = string
  description = "Primary CIDR"
  default     = "10.10.0.0/16"
}
