provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      project    = "aws-infra"
      managed-by = "terraform"
      owner      = "unixovich"
      module     = local.module_name
    }
  }
}
