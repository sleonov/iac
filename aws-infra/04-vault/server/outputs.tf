output "vault_instance_id" {
  value = aws_instance.vault.id
}

output "vault_private_ip" {
  value = aws_instance.vault.private_ip
}

output "vault_s3_bucket" {
  value = aws_s3_bucket.vault_storage.id
}

output "vault_kms_key_arn" {
  value = aws_kms_key.vault_unseal.arn
}

output "vault_init_secret_arn" {
  value = aws_secretsmanager_secret.vault_init.arn
}
