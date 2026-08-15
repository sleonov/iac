terraform {
  required_version = ">=1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.34.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">=4.0.0"
    }
  }

  backend "s3" {
    key = "aws-infra/04-vault/bootstrap/terraform.tfstate"
  }
}
