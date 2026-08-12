locals {
  module_name            = "02-networking/core-dns"
  east_vpc_id            = data.terraform_remote_state.core_vpcs.outputs.east_vpc_id
  west_vpc_id            = data.terraform_remote_state.core_vpcs.outputs.west_vpc_id
  east_private_zone_name = "use1.internal.${var.public_zone_name}"
  west_private_zone_name = "usw1.internal.${var.public_zone_name}"
}
