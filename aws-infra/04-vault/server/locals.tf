locals {
  module_name  = "04-vault/server"
  state_bucket = "terraform-state-607527010331"

  vpc_id    = data.terraform_remote_state.core_vpcs.outputs.east_vpc_id
  subnet_id = data.terraform_remote_state.core_subnets.outputs.east_private_subnets.az_a.id
}
