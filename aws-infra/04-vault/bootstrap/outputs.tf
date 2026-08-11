output "kv_mount_path" {
  value = vault_mount.kv.path
}

output "approle_accessor" {
  value = vault_auth_backend.approle.accessor
}

output "aws_auth_accessor" {
  value = vault_auth_backend.aws.accessor
}
