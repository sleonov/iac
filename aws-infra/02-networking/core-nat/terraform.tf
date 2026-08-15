terraform {
  required_version = ">=1.10.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">=6.34.0"
      configuration_aliases = [aws.east, aws.west]
    }
  }

  backend "s3" {
    key = "aws-infra/02-networking/core-nat/terraform.tfstate"
  }
}
