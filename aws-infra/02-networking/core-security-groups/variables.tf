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

variable "ingress_ports" {
  type = map(object({
    port_no = number
    proto   = string
  }))
  default = {
    SSH   = { port_no = 22, proto = "tcp" }
    HTTPS = { port_no = 443, proto = "tcp" }
  }
}
