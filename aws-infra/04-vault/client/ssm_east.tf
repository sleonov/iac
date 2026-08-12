resource "aws_ssm_parameter" "instance_id" {
  name  = "/tf/aws-infra/vault/client/instance-id"
  type  = "String"
  value = aws_instance.vault_client.id
}
