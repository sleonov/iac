## AWS infra setup

> **NOTE:**
> - This document describes the bootstrap of a sample AWS infrastructure using Terraform.
> - Requires Terraform ≥1.10 and AWS provider ≥6.34.0.
> - AWS authentication relies on the `AWS_PROFILE` environment variable — ensure it is set before running any Terraform commands, e.g. `export AWS_PROFILE=<your-profile>`.

## Table of Contents

- [Remote State](#remote-state)
- [01-bootstrap](#01-bootstrap)

## Remote State

All modules store state in S3 bucket `terraform-state-607527010331`. It is created in `01-bootstrap` step, using local state.

| Module                  | State key                                             |
|-------------------------|-------------------------------------------------------|
| 02-networking/vpc       | `aws-infra/02-networking/vpc/terraform.tfstate`       |
| 02-networking/subnets   | `aws-infra/02-networking/subnets/terraform.tfstate`   |
| 03-vault                | `aws-infra/03-vault/terraform.tfstate`                |

## 01-bootstrap

**Variables**

| Variable             | Default             | Description                        |
|----------------------|---------------------|------------------------------------|
| `region`             | `us-east-1`         | AWS region                         |
| `bucket_name_prefix` | `terraform-state`   | Prefix for the state bucket name   |

**Resources**

| Resource                                      | Description                                             |
|-----------------------------------------------|---------------------------------------------------------|
| `aws_s3_bucket`                               | State bucket named `<bucket_name_prefix>-<account-id>` |
| `aws_s3_bucket_versioning`                    | Enables versioning on the state bucket                  |
| `aws_s3_bucket_server_side_encryption_configuration` | AES256 encryption                              |
| `aws_s3_bucket_public_access_block`           | Blocks all public access                                |

Native S3 state locking is enabled via `use_lockfile = true` — no DynamoDB table required.

**Outputs**

| Output                | Description              |
|-----------------------|--------------------------|
| `state_bucket_name`   | Name of the S3 bucket    |
| `state_bucket_arn`    | ARN of the S3 bucket     |

**`locals.tf` template** — set `module_name` to the full relative path of the module:

```hcl
locals {
  module_name = "<module-path>"  # e.g. "02-networking/vpc"
}
```

**`providers.tf` template** — use this in every module:

```hcl
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project    = "aws-infra"
      managed-by = "terraform"
      owner      = "unixovich"
      module     = local.module_name
    }
  }
}
```

**Backend template** — add this to `terraform.tf`, replacing `key` with the module-specific path:

```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-state-<account-id>"
    key          = "<module-name>/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
```
