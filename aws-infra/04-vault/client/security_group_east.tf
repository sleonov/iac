resource "aws_security_group" "vault_client" {
  provider    = aws.east
  name        = "vault-client"
  description = "Vault client - outbound only, SSM access via instance profile"
  vpc_id      = local.vpc_id
  tags = {
    Name = "vault-client"
  }
}

# Allow all outbound — needed for SSM, HashiCorp repo, and Vault API calls
resource "aws_vpc_security_group_egress_rule" "vault_client_all" {
  provider          = aws.east
  security_group_id = aws_security_group.vault_client.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
