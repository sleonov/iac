variable "east_region" {
  type    = string
  default = "us-east-1"
}

variable "west_region" {
  type    = string
  default = "us-west-1"
}

variable "bucket_name_prefix" {
  type    = string
  default = "terraform-state"
}
