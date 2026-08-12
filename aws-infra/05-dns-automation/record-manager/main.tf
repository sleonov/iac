data "terraform_remote_state" "core_dns" {
  backend = "s3"
  config = {
    bucket = "terraform-state-607527010331"
    key    = "aws-infra/02-networking/core-dns/terraform.tfstate"
    region = "us-east-1"
  }
}
