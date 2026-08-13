terraform {
  required_version = ">=1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.34.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">=2.0.0"
    }
  }

  backend "s3" {
    bucket       = "terraform-state-607527010331"
    key          = "aws-infra/05-dns-automation/record-reaper/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
