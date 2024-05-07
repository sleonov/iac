terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "sleonov-green"
  default_tags {
    tags = {
      "project-id" = var.project_id
    }
  }
}