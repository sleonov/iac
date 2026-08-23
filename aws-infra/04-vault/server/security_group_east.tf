resource "aws_security_group" "vault" {
  provider    = aws.east
  name        = "vault-server"
  description = "Vault server - allows Vault API access from both VPCs"
  vpc_id      = local.vpc_id
  tags = {
    Name = "vault-server"
  }
}

# Allow Vault API from east VPC
resource "aws_vpc_security_group_ingress_rule" "vault_api_east" {
  provider          = aws.east
  security_group_id = aws_security_group.vault.id
  ip_protocol       = "tcp"
  from_port         = 8200
  to_port           = 8200
  cidr_ipv4         = data.terraform_remote_state.core_vpcs.outputs.east_vpc_cidr
  description       = "Vault API from east VPC"
}

# Allow Vault API from west VPC
resource "aws_vpc_security_group_ingress_rule" "vault_api_west" {
  provider          = aws.east
  security_group_id = aws_security_group.vault.id
  ip_protocol       = "tcp"
  from_port         = 8200
  to_port           = 8200
  cidr_ipv4         = data.terraform_remote_state.core_vpcs.outputs.west_vpc_cidr
  description       = "Vault API from west VPC"
}

# Allow all outbound — needed for KMS and S3 API calls
resource "aws_vpc_security_group_egress_rule" "vault_all" {
  provider          = aws.east
  security_group_id = aws_security_group.vault.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
