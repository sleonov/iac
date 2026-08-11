data "aws_secretsmanager_secret_version" "vault_init" {
  secret_id = "vault/init"
}

data "terraform_remote_state" "vault_server" {
  backend = "s3"
  config = {
    bucket  = "terraform-state-607527010331"
    key     = "aws-infra/04-vault/server/terraform.tfstate"
    region  = "us-east-1"
  }
}
