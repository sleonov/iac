provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project    = "aws-infra"
      managed-by = "terraform"
      owner      = "unixovich"
      module     = local.module_name
    }
  }
}
