locals {
  module_name = "04-vault/client"

  vpc_id               = data.terraform_remote_state.core_vpcs.outputs.east_vpc_id
  subnet_id            = data.terraform_remote_state.core_subnets.outputs.east_private_subnets.az_a.id
  instance_profile_name = data.terraform_remote_state.bastion.outputs.bastion_instance_profile_name
}
