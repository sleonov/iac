locals {
  module_name = "02-networking/core-security-groups"
  east_vpc_id = data.terraform_remote_state.core_vpcs.outputs.east_vpc_id
  west_vpc_id = data.terraform_remote_state.core_vpcs.outputs.west_vpc_id
}
