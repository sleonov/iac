terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "green-terraform-backend"
    key            = "web-instance/terraform.tfstate"
    dynamodb_table = "green-terraform-backend"
  }
}

provider "aws" {
  default_tags {
    tags = {
      "Environment" = "Test"
      "Project"     = "Terraform"
      "Operation"   = "Nokia"
    }
  }
}
