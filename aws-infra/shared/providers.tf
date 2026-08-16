# Canonical provider configuration — shared across all modules via symlink.
# Each module's providers.tf symlinks here; edit this file to update all modules at once.
# Exception: 04-vault/bootstrap keeps its own providers.tf (AWS + Vault providers).
#
# Symlinking a new module:
#   depth-1 (e.g. 01-bootstrap/):             ln -s ../shared/providers.tf providers.tf
#   depth-2 (e.g. 02-networking/core-vpcs/):  ln -s ../../shared/providers.tf providers.tf

provider "aws" {
  alias  = "east"
  region = var.east_region

  default_tags {
    tags = {
      project    = "aws-infra"
      managed-by = "terraform"
      owner      = "unixovich"
      module     = local.module_name
    }
  }
}

provider "aws" {
  alias  = "west"
  region = var.west_region

  default_tags {
    tags = {
      project    = "aws-infra"
      managed-by = "terraform"
      owner      = "unixovich"
      module     = local.module_name
    }
  }
}
