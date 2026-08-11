variable "path_to_password" {
  type    = string
  default = "/mysql/admin/password"
}

variable "password_length" {
  type    = number
  default = 20
}