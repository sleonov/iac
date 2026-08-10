locals {
  module_name = "02-networking/core-routing"

  east_vpc_id   = data.terraform_remote_state.core_vpcs.outputs.east_vpc_id
  west_vpc_id   = data.terraform_remote_state.core_vpcs.outputs.west_vpc_id
  east_vpc_cidr = data.terraform_remote_state.core_vpcs.outputs.east_vpc_cidr
  west_vpc_cidr = data.terraform_remote_state.core_vpcs.outputs.west_vpc_cidr

  east_public_subnet_a_id  = data.terraform_remote_state.core_subnets.outputs.east_public_subnets.az_a.id
  east_public_subnet_b_id  = data.terraform_remote_state.core_subnets.outputs.east_public_subnets.az_b.id
  east_private_subnet_a_id = data.terraform_remote_state.core_subnets.outputs.east_private_subnets.az_a.id
  east_private_subnet_b_id = data.terraform_remote_state.core_subnets.outputs.east_private_subnets.az_b.id

  west_public_subnet_a_id  = data.terraform_remote_state.core_subnets.outputs.west_public_subnets.az_a.id
  west_public_subnet_b_id  = data.terraform_remote_state.core_subnets.outputs.west_public_subnets.az_b.id
  west_private_subnet_a_id = data.terraform_remote_state.core_subnets.outputs.west_private_subnets.az_a.id
  west_private_subnet_b_id = data.terraform_remote_state.core_subnets.outputs.west_private_subnets.az_b.id
}
