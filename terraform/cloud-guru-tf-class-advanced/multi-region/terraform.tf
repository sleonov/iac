terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "sleonov-green"
  region  = "us-east-1"
  alias   = "virginia"
}

provider "aws" {
  profile = "sleonov-green"
  region  = "us-west-2"
  alias   = "oregon"
}
