variable "vpc_name" {
  description = "Name tag of the target vpc"
  type        = string
  default     = "green-vpc-1"
}

variable "subnet_name" {
  description = "Name tag of the target subnet in target vpc"
  type        = string
  default     = "application-a"
}
