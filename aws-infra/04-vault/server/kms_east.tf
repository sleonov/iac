resource "aws_kms_key" "vault_unseal" {
  provider                = aws.east
  description             = "Vault auto-unseal key"
  deletion_window_in_days = 7    # minimum allowed by AWS; shortened for dev to reduce re-apply wait time
  enable_key_rotation     = true # AWS rotates key material annually; key ID and alias remain unchanged
}

# Human-readable alias — Vault's KMS seal config references this instead of the raw key ID.
# WARNING: after terraform destroy, the key enters a pending deletion window (7 days).
# Re-applying within that window will fail because this alias still exists on the pending-deletion key.
# Fix: manually delete the alias in the AWS console before re-applying, or wait 7 days.
resource "aws_kms_alias" "vault_unseal" {
  provider      = aws.east
  name          = "alias/vault-unseal"
  target_key_id = aws_kms_key.vault_unseal.key_id
}
