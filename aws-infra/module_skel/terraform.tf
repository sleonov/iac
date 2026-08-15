terraform {
  required_version = ">=1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.34.0"
    }
  }

  backend "s3" {
    key = "<module-path>/terraform.tfstate" # e.g. "aws-infra/02-networking/core-vpcs/terraform.tfstate"
  }
}
