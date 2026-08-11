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
    bucket       = "terraform-state-607527010331"
    key          = "aws-infra/02-networking/core-nat/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
