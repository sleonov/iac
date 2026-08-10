## AWS infra setup

## Shared Configuration

| Parameter      | Value                          |
|----------------|-------------------------------|
| State bucket   | `terraform-state-607527010331` |
| AWS region     | `us-east-1`                   |
| AWS profile    | `sleonov`                     |
| Account ID     | `607527010331`                 |

### Remote state key convention

Each module stores its state at `aws-infra/<module-name>/terraform.tfstate`:

| Module          | State key                                    |
|-----------------|----------------------------------------------|
| 01-bootstrap    | local only (creates the bucket)              |
| 02-networking   | `aws-infra/02-networking/terraform.tfstate`  |
| 03-vault        | `aws-infra/03-vault/terraform.tfstate`       |

## Table of Contents

- [01-bootstrap](#01-bootstrap)

### 01-bootstrap

Creates the S3 bucket used as Terraform remote state backend for all subsequent modules. Uses local state (stored in `terraform.tfstate`) since it bootstraps the infrastructure needed by everything else.

Resources created:
- S3 bucket named `<project>-<account-id>` with versioning and AES256 server-side encryption enabled, public access fully blocked

No DynamoDB table is created for state locking — Terraform ≥1.10 supports native S3 locking via the bucket's built-in conditional writes, making a separate DynamoDB table unnecessary.

Outputs: `state_bucket_name`, `state_bucket_arn`

**Usage in other modules** — add this backend block to `terraform.tf`, replacing `key` with the module-specific path:

```hcl
terraform {
  backend "s3" {
    bucket       = "terraform-state-<account-id>"
    key          = "<module-name>/terraform.tfstate"
    region       = "us-east-1"
    profile      = "sleonov"
    use_lockfile = true
    encrypt      = true
  }
}
```
