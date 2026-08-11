resource "aws_secretsmanager_secret" "vault_init" {
  name                    = "vault/init"
  recovery_window_in_days = 7
}
