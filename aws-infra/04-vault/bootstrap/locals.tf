locals {
  module_name   = "04-vault/bootstrap"
  vault_address = "http://127.0.0.1:8200"
  root_token    = jsondecode(data.aws_secretsmanager_secret_version.vault_init.secret_string)["root_token"]
}
