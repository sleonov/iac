# Single-region module. For multi-region, use aliased providers with separate region variables.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project    = "aws-infra"
      managed-by = "terraform"
      owner      = "unixovich"
      module     = local.module_name
    }
  }
}

# Vault is in a private subnet — requires SSM port forwarding before apply.
# Use `make vault-bootstrap` from aws-infra/ — tunnel is managed automatically by scripts/vault-tunnel.sh.
# To open the tunnel manually:
#   aws ssm start-session \
#     --target $(aws ssm get-parameter --name /tf/aws-infra/vault/server/instance-id --query Parameter.Value --output text) \
#     --document-name AWS-StartPortForwardingSession \
#     --parameters portNumber=8200,localPortNumber=8200
provider "vault" {
  address         = local.vault_address
  token           = local.root_token
  skip_tls_verify = true # TLS disabled in dev; remove when tls_disable = false in vault.hcl
}
