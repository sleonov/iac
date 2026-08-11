terraform {
  backend "s3" {
    profile        = "sleonov-green"
    region         = "us-east-1"
    bucket         = "green-terraform-backend"
    key            = "web-instance/terraform.tfstate"
    dynamodb_table = "green-terraform-backend"
  }
}
