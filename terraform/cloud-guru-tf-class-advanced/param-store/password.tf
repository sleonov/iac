resource "aws_ssm_parameter" "admin_password" {
  name  = var.path_to_password
  type  = "SecureString"
  value = data.aws_secretsmanager_random_password.this.random_password
}

data "aws_secretsmanager_random_password" "this" {
  password_length = var.password_length
}