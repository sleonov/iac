resource "aws_secretsmanager_secret" "vault_init" {
  provider                = aws.east
  name                    = "vault/init"
  recovery_window_in_days = 7
}
