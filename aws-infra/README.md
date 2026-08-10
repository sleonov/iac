## AWS infra setup

> **NOTE:**
> - This document describes the bootstrap of a sample AWS infrastructure using Terraform.
> - Requires Terraform ≥1.10 and AWS provider ≥6.34.0.
> - AWS authentication relies on the `AWS_PROFILE` environment variable — ensure it is set before running any Terraform commands, e.g. `export AWS_PROFILE=<your-profile>`.

## Table of Contents

- [Remote State](#remote-state)
- [New Module Bootstrap](#new-module-bootstrap)
- [01-bootstrap](#01-bootstrap)
- [02-networking](#02-networking)
  - [core-vpcs](#core-vpcs)
  - [core-subnets](#core-subnets)
  - [core-routing](#core-routing)

## Remote State

All modules store state in S3 bucket `terraform-state-607527010331`. It is created in `01-bootstrap` step, using local state.

| Module                      | State key                                                 |
|-----------------------------|-----------------------------------------------------------|
| 02-networking/core-vpcs     | `aws-infra/02-networking/core-vpcs/terraform.tfstate`     |
| 02-networking/core-subnets  | `aws-infra/02-networking/core-subnets/terraform.tfstate`  |
| 02-networking/core-routing  | `aws-infra/02-networking/core-routing/terraform.tfstate`  |
| 03-vault                    | `aws-infra/03-vault/terraform.tfstate`                    |

## New Module Bootstrap

Copy files from `module_skel/` into the new module directory and replace the `<module-path>` placeholders in `locals.tf` and `terraform.tf` with the module's relative path (e.g. `02-networking/core-vpcs`).

## 01-bootstrap

Native S3 state locking via `use_lockfile = true` — no DynamoDB table required.

**Resources:** `aws_s3_bucket`, `aws_s3_bucket_versioning`, `aws_s3_bucket_server_side_encryption_configuration`, `aws_s3_bucket_public_access_block`

**Outputs:** `state_bucket_name`, `state_bucket_arn`

## 02-networking

Creates resources in east and west regions for core networking infrastructure.

### core-vpcs

**Resources:** `aws_vpc.east`, `aws_vpc.west`

**Outputs:** `east_vpc_id`, `west_vpc_id`, `east_vpc_cidr`, `west_vpc_cidr`

### core-subnets

VPC CIDRs are retrieved from `core-vpcs` remote state. Subnet CIDRs are derived dynamically from those using `cidrsubnet()` — see [docs](https://developer.hashicorp.com/terraform/language/functions/cidrsubnet). AZs are resolved at runtime using `aws_availability_zones` filtered by `zone-type = availability-zone` to exclude Local Zones and Wavelength Zones.

**Resources:** `aws_subnet.east_private_a`, `aws_subnet.east_private_b`, `aws_subnet.east_public_a`, `aws_subnet.east_public_b`, `aws_subnet.west_private_a`, `aws_subnet.west_private_b`, `aws_subnet.west_public_a`, `aws_subnet.west_public_b`

**Outputs:** `east_private_subnets`, `east_public_subnets`, `west_private_subnets`, `west_public_subnets`

### core-routing

VPC peering between east (`us-east-1`) and west (`us-west-1`) regions. Routes added to all public and private route tables. Private subnets have local routing only (no NAT).

**Resources:** `aws_internet_gateway.east`, `aws_internet_gateway.west`, `aws_route_table.east_public`, `aws_route_table.east_private`, `aws_route_table.west_public`, `aws_route_table.west_private`, `aws_vpc_peering_connection.east_to_west`

**Outputs:** `east_igw_id`, `west_igw_id`, `east_public_route_table_id`, `east_private_route_table_id`, `west_public_route_table_id`, `west_private_route_table_id`, `vpc_peering_connection_id`
