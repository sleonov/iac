resource "aws_ssm_parameter" "kv_mount" {
  name  = "/tf/aws-infra/vault/bootstrap/kv-mount-path"
  type  = "String"
  value = vault_mount.kv.path
}
