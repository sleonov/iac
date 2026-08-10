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

## Remote State

All modules store state in S3 bucket `terraform-state-607527010331`. It is created in `01-bootstrap` step, using local state.

| Module                  | State key                                             |
|-------------------------|-------------------------------------------------------|
| 02-networking/core-vpcs | `aws-infra/02-networking/core-vpcs/terraform.tfstate` |
| 03-vault                | `aws-infra/03-vault/terraform.tfstate`                |

## New Module Bootstrap

Copy files from `module_skel/` into the new module directory and replace the `<module-path>` placeholders in `locals.tf` and `terraform.tf` with the module's relative path (e.g. `02-networking/core-vpcs`).

## 01-bootstrap

Native S3 state locking via `use_lockfile = true` — no DynamoDB table required.

| Name                                                 | Type     | Description                                            |
|------------------------------------------------------|----------|--------------------------------------------------------|
| `aws_s3_bucket.terraform_state`                                      | resource | State bucket named `<bucket_name_prefix>-<account-id>` |
| `aws_s3_bucket_versioning.terraform_state`                           | resource | Versioning enabled                                     |
| `aws_s3_bucket_server_side_encryption_configuration.terraform_state` | resource | AES256 encryption                                      |
| `aws_s3_bucket_public_access_block.terraform_state`                  | resource | All public access blocked                              |
| `state_bucket_name`                                  | output   | Name of the S3 bucket                                  |
| `state_bucket_arn`                                   | output   | ARN of the S3 bucket                                   |

## 02-networking

Creates resources in east and west regions for core networking infrastructure.

### core-vpcs

| Name            | Type     | Description                                     |
|-----------------|----------|-------------------------------------------------|
| `aws_vpc.east`  | resource | East VPC (`us-east-1`) with DNS support enabled |
| `aws_vpc.west`  | resource | West VPC (`us-west-1`) with DNS support enabled |
| `east_vpc_id`   | output   | ID of the east VPC                              |
| `west_vpc_id`   | output   | ID of the west VPC                              |
| `east_vpc_cidr` | output   | CIDR block of the east VPC                      |
| `west_vpc_cidr` | output   | CIDR block of the west VPC                      |
