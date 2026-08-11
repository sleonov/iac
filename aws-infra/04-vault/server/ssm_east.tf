resource "aws_ssm_parameter" "instance_id" {
  name  = "/tf/aws-infra/vault/server/instance-id"
  type  = "String"
  value = aws_instance.vault.id
}

resource "aws_ssm_parameter" "private_ip" {
  name  = "/tf/aws-infra/vault/server/private-ip"
  type  = "String"
  value = aws_instance.vault.private_ip
}

resource "aws_ssm_parameter" "s3_bucket" {
  name  = "/tf/aws-infra/vault/server/s3-bucket"
  type  = "String"
  value = aws_s3_bucket.vault_storage.id
}

resource "aws_ssm_parameter" "kms_key_arn" {
  name  = "/tf/aws-infra/vault/server/kms-key-arn"
  type  = "String"
  value = aws_kms_key.vault_unseal.arn
}

resource "aws_ssm_parameter" "init_secret_arn" {
  name  = "/tf/aws-infra/vault/server/init-secret-arn"
  type  = "String"
  value = aws_secretsmanager_secret.vault_init.arn
}
