terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  profile = "sleonov-green"
  region = "us-east-1"
}