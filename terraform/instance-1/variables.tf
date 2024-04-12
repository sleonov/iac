variable "my_instance_ami" {
  description = "AMI id"
  type        = string
  validation {
    condition     = substr(var.my_instance_ami, 0, 4) == "ami-"
    error_message = "Invalid AMI ID!"
  }
}

variable "my_region" {
  description = "AWS Region"
  type        = string
}

variable "my_instance_type" {
  description = "Instance type"
  type        = string
  sensitive   = true
}

variable "my_instance_subnet" {
  description = "Subnet to deploy instance in"
  type        = string
  validation {
    condition     = substr(var.my_instance_subnet, 0, 7) == "subnet-"
    error_message = "Invalid Subnet ID!"
  }
}