# Single-region module. For multi-region, use aliased providers with separate region variables.
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
