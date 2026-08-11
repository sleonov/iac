data "aws_secretsmanager_secret_version" "vault_init" {
  secret_id = "vault/init"
}
