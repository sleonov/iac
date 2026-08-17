locals {
  module_name  = "02-networking/core-security-groups"
  state_bucket = "terraform-state-607527010331"
  east_vpc_id  = data.terraform_remote_state.core_vpcs.outputs.east_vpc_id
  west_vpc_id  = data.terraform_remote_state.core_vpcs.outputs.west_vpc_id
}
