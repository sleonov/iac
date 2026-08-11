provider "aws" {
  region  = "us-east-1"
  profile = "sleonov-green"
  default_tags {
    tags = {
      Environment = "test"
      Project     = "web-server"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}