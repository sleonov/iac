locals {
  module_name          = "05-dns-automation/record-manager"
  east_private_zone_id = data.terraform_remote_state.core_dns.outputs.east_private_zone_id
  west_private_zone_id = data.terraform_remote_state.core_dns.outputs.west_private_zone_id
}
