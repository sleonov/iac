locals {
  module_name = "02-networking/core-subnets"

  east_vpc_id   = data.terraform_remote_state.core_vpcs.outputs.east_vpc_id
  east_vpc_cidr = data.terraform_remote_state.core_vpcs.outputs.east_vpc_cidr
  west_vpc_id   = data.terraform_remote_state.core_vpcs.outputs.west_vpc_id
  west_vpc_cidr = data.terraform_remote_state.core_vpcs.outputs.west_vpc_cidr

  east_az_a = data.aws_availability_zones.east.names[0]
  east_az_b = data.aws_availability_zones.east.names[1]
  west_az_a = data.aws_availability_zones.west.names[0]
  west_az_b = data.aws_availability_zones.west.names[1]

  east_public_az_a_cidr  = cidrsubnet(local.east_vpc_cidr, 8, 0)  # 10.1.0.0/24
  east_public_az_b_cidr  = cidrsubnet(local.east_vpc_cidr, 8, 1)  # 10.1.1.0/24
  east_private_az_a_cidr = cidrsubnet(local.east_vpc_cidr, 8, 10) # 10.1.10.0/24
  east_private_az_b_cidr = cidrsubnet(local.east_vpc_cidr, 8, 11) # 10.1.11.0/24

  west_public_az_a_cidr  = cidrsubnet(local.west_vpc_cidr, 8, 0)  # 10.10.0.0/24
  west_public_az_b_cidr  = cidrsubnet(local.west_vpc_cidr, 8, 1)  # 10.10.1.0/24
  west_private_az_a_cidr = cidrsubnet(local.west_vpc_cidr, 8, 10) # 10.10.10.0/24
  west_private_az_b_cidr = cidrsubnet(local.west_vpc_cidr, 8, 11) # 10.10.11.0/24
}
