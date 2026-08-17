locals {
  module_name  = "02-networking/core-nat"
  state_bucket = "terraform-state-607527010331"

  east_public_subnet_a_id = data.terraform_remote_state.core_subnets.outputs.east_public_subnets.az_a.id
  east_private_rt_id      = data.terraform_remote_state.core_routing.outputs.east_private_route_table_id

  west_public_subnet_a_id = data.terraform_remote_state.core_subnets.outputs.west_public_subnets.az_a.id
  west_private_rt_id      = data.terraform_remote_state.core_routing.outputs.west_private_route_table_id

  nat_instance_profile = data.terraform_remote_state.iam_bastion.outputs.bastion_instance_profile_name

  east_vpc_id   = data.terraform_remote_state.core_vpcs.outputs.east_vpc_id
  east_vpc_cidr = data.terraform_remote_state.core_vpcs.outputs.east_vpc_cidr
  west_vpc_id   = data.terraform_remote_state.core_vpcs.outputs.west_vpc_id
  west_vpc_cidr = data.terraform_remote_state.core_vpcs.outputs.west_vpc_cidr
}
