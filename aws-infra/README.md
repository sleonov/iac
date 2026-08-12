> **WARNING:** This repository is provided for educational purposes only. The author is not liable for any damage, data loss, or costs incurred as a result of using this code. Use at your own risk.

## AWS infra setup

> **NOTE:**
> - This document describes the bootstrap of a sample AWS infrastructure using Terraform.
> - Requires Terraform ≥1.10 and AWS provider ≥6.34.0.
> - AWS authentication relies on the `AWS_PROFILE` environment variable — ensure it is set before running any Terraform commands, e.g. `export AWS_PROFILE=<your-profile>`.

## Table of Contents

- [Setup](#setup)
- [Scripts](#scripts)
- [Provider](#provider)
- [Remote State](#remote-state)
- [Modules](#modules)
  - [01-bootstrap](#01-bootstrap)
  - [02-networking](#02-networking)
    - [core-vpcs](#core-vpcs)
    - [core-subnets](#core-subnets)
    - [core-routing](#core-routing)
    - [core-security-groups](#core-security-groups)
    - [core-nat](#core-nat)
  - [03-iam](#03-iam)
    - [bastion](#bastion)
  - [04-vault](#04-vault)
    - [server](#server)
    - [bootstrap](#bootstrap)
    - [client](#client)
- [New Module Bootstrap](#new-module-bootstrap)
- [Diagrams](#diagrams)
  - [Network Resources Diagram](#network-resources-diagram)
  - [Vault Resources Diagram](#vault-resources-diagram)
  - [Vault Client Diagram](#vault-client-diagram)

---

## Setup

Set AWS credentials before applying any module:
```bash
export AWS_PROFILE=<your-profile>
```
The profile must have broad permissions to create and delete VPCs, subnets, EC2 instances, IAM roles, and S3 buckets; admin-level access is recommended.

**How modules depend on each other:**

Each module is independently deployable — there is no Terraform nesting or module calls between them. Instead, downstream modules declare `data "terraform_remote_state"` blocks in `main.tf` to read outputs written by upstream modules to the shared S3 state backend. If an upstream module has not been applied yet, the plan fails immediately with a remote state read error. This makes dependencies explicit and enforces the apply order at plan time rather than silently producing incomplete infrastructure.

For consumers outside the Terraform ecosystem — scripts, CI pipelines, application config — key outputs are also published to SSM Parameter Store. This avoids coupling non-Terraform tooling to the S3 state backend. See the [Remote State](#remote-state) section for SSM path conventions.

**Apply order and dependencies:**

`01-bootstrap` must be applied before any other module — it creates the S3 bucket used as the Terraform state backend by every other module.

| # | Module | Depends on |
|---|--------|-----------|
| 1 | `02-networking/core-vpcs` | — |
| 2 | `02-networking/core-subnets` | `core-vpcs` |
| 3 | `02-networking/core-routing` | `core-vpcs`, `core-subnets` |
| 4 | `03-iam/bastion` | — |
| 5 | `02-networking/core-security-groups` | `core-vpcs` |
| 6 | `02-networking/core-nat` *(optional)* | `core-vpcs`, `core-subnets`, `core-routing`, `03-iam/bastion` |
| 7 | `04-vault/server` | `core-vpcs`, `core-subnets`; `core-nat` must be running |
| 8 | `04-vault/bootstrap` | `04-vault/server` applied and initialized; use `make vault-bootstrap` |
| 9 | `04-vault/client` | `core-vpcs`, `core-subnets`, `03-iam/bastion`, `04-vault/server`; `core-nat` must be running |

`core-nat` is optional — only needed when workloads in private subnets require internet access. `04-vault/server` always requires `core-nat` to be running (Vault needs it to reach KMS and S3 on startup).

**Applying modules:**

For each module: `cd <module-dir> && terraform init && terraform apply`

A `Makefile` at the root of `aws-infra/` provides shorthand targets for each module. The `vault-bootstrap` target also handles the SSM tunnel automatically.

- `make vault-server` — apply
- `make vault-server PLAN=1` — plan
- `make vault-server DESTROY=1` — destroy

---

## Scripts

Three scripts in `scripts/` handle SSM-based access patterns used by Makefile targets and direct CLI use:

- [scripts/vault-tunnel.sh](scripts/vault-tunnel.sh) `<region> <command>` — opens an SSM port-forwarding tunnel from `localhost:8200` to the Vault instance, waits for the Vault API to respond, runs the given command, then tears the tunnel down. Used by `make vault-bootstrap` and `make vault-status`.
- [scripts/ssm-run.sh](scripts/ssm-run.sh) `<region> <ssm-param-path> <command> [command...]` — looks up an instance ID from SSM Parameter Store, runs one or more shell commands on that instance via SSM Send-Command, polls until complete, and prints stdout. Used by `make core-nat-status`.
- [scripts/vault-ssm-session.sh](scripts/vault-ssm-session.sh) `server|client [region]` — opens an interactive SSM shell session on the Vault server or client instance, with an instance state check before attempting to connect.

---

## Provider

All modules use the [AWS Terraform provider](https://registry.terraform.io/providers/hashicorp/aws/latest) (`hashicorp/aws`). The provider translates Terraform resource definitions into AWS API calls, managing the full lifecycle of AWS resources (create, read, update, delete).

- [Registry page](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub](https://github.com/hashicorp/terraform-provider-aws)

---

## Remote State

All modules store state in S3 bucket `terraform-state-607527010331`. It is created in `01-bootstrap` step, using local state.

| Module                              | State key                                                         |
|-------------------------------------|-------------------------------------------------------------------|
| [02-networking/core-vpcs](02-networking/core-vpcs) | `aws-infra/02-networking/core-vpcs/terraform.tfstate` |
| [02-networking/core-subnets](02-networking/core-subnets) | `aws-infra/02-networking/core-subnets/terraform.tfstate` |
| [02-networking/core-routing](02-networking/core-routing) | `aws-infra/02-networking/core-routing/terraform.tfstate` |
| [02-networking/core-security-groups](02-networking/core-security-groups) | `aws-infra/02-networking/core-security-groups/terraform.tfstate` |
| [02-networking/core-nat](02-networking/core-nat) | `aws-infra/02-networking/core-nat/terraform.tfstate` |
| [03-iam/bastion](03-iam/bastion) | `aws-infra/03-iam/bastion/terraform.tfstate` |
| [04-vault/server](04-vault/server) | `aws-infra/04-vault/server/terraform.tfstate` |
| [04-vault/client](04-vault/client) | `aws-infra/04-vault/client/terraform.tfstate` |
| [04-vault/bootstrap](04-vault/bootstrap) | `aws-infra/04-vault/bootstrap/terraform.tfstate` |

---

## Modules

### 01-bootstrap

Native S3 state locking via `use_lockfile = true` — no DynamoDB table required.

**Resource types:** [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket), [aws_s3_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning), [aws_s3_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration), [aws_s3_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)

**Resources:**
- `aws_s3_bucket` — state bucket
- `aws_s3_bucket_versioning` — versioning enabled
- `aws_s3_bucket_server_side_encryption_configuration` — AES256 encryption
- `aws_s3_bucket_public_access_block` — all public access blocked

**Outputs:**
- `state_bucket_name` — bucket name
- `state_bucket_arn` — bucket ARN

---

### 02-networking

Creates resources in east and west regions for core networking infrastructure.

---

### core-vpcs

**Resource types:** [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)

**Resources:**
- `aws_vpc.east` — east VPC (`us-east-1`) with DNS support enabled
- `aws_vpc.west` — west VPC (`us-west-1`) with DNS support enabled

**Outputs:**
- `east_vpc_id`, `west_vpc_id` — VPC IDs
- `east_vpc_cidr`, `west_vpc_cidr` — VPC CIDR blocks

---

### core-subnets

VPC CIDRs are retrieved from `core-vpcs` remote state. Subnet CIDRs are derived dynamically from those using `cidrsubnet()` — see [docs](https://developer.hashicorp.com/terraform/language/functions/cidrsubnet). AZs are resolved at runtime using `aws_availability_zones` filtered by `zone-type = availability-zone` to exclude Local Zones and Wavelength Zones.

**Resource types:** [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

**Resources:**
- `aws_subnet.east_private_a`, `aws_subnet.east_private_b` — east private subnets
- `aws_subnet.east_public_a`, `aws_subnet.east_public_b` — east public subnets
- `aws_subnet.east_db_a`, `aws_subnet.east_db_b` — east database subnets
- `aws_subnet.west_private_a`, `aws_subnet.west_private_b` — west private subnets
- `aws_subnet.west_public_a`, `aws_subnet.west_public_b` — west public subnets
- `aws_subnet.west_db_a`, `aws_subnet.west_db_b` — west database subnets

**Outputs:**
- `east_private_subnets`, `east_public_subnets`, `east_db_subnets` — east subnet maps (id, cidr, az, vpc_id per subnet)
- `west_private_subnets`, `west_public_subnets`, `west_db_subnets` — west subnet maps (id, cidr, az, vpc_id per subnet)

---

### core-routing

VPC peering between east (`us-east-1`) and west (`us-west-1`) regions. Private subnets route internet-bound traffic through fck-nat instances (added by `core-nat`). DB subnets are fully isolated — local routing only, no IGW or peering routes.

Route tables are defined in `route_tables.tf`. Routes are added separately as `aws_route` resources in `igw.tf` and `vpc_peering.tf`.

**Resource types:** [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway), [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table), [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association), [aws_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route), [aws_vpc_peering_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection), [aws_vpc_peering_connection_accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter)

| Route table | Routes |
|---|---|
| `rt-east-public` | `0.0.0.0/0 → igw-east`, `10.10.0.0/16 → pcx` |
| `rt-east-private` | `10.10.0.0/16 → pcx`, `0.0.0.0/0 → fck-nat-east` _(added by core-nat)_ |
| `rt-east-db` | local only |
| `rt-west-public` | `0.0.0.0/0 → igw-west`, `10.1.0.0/16 → pcx` |
| `rt-west-private` | `10.1.0.0/16 → pcx`, `0.0.0.0/0 → fck-nat-west` _(added by core-nat)_ |
| `rt-west-db` | local only |

**Resources:**
- `aws_internet_gateway.east`, `aws_internet_gateway.west` — internet gateways attached to each VPC
- `aws_route_table.east_public`, `aws_route_table.east_private`, `aws_route_table.east_db` — east route tables with subnet associations
- `aws_route_table.west_public`, `aws_route_table.west_private`, `aws_route_table.west_db` — west route tables with subnet associations
- `aws_vpc_peering_connection.east_to_west` — cross-region VPC peering connection

**Outputs:**
- `east_igw_id`, `west_igw_id` — internet gateway IDs
- `east_public_route_table_id`, `east_private_route_table_id`, `east_db_route_table_id` — east route table IDs
- `west_public_route_table_id`, `west_private_route_table_id`, `west_db_route_table_id` — west route table IDs
- `vpc_peering_connection_id` — VPC peering connection ID

---

### core-security-groups

VPC IDs are retrieved from `core-vpcs` remote state. SSH ingress is restricted to `bastion_allowed_cidr` — set this to your public IP in `terraform.tfvars`.

**Resource types:** [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group), [aws_vpc_security_group_ingress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule), [aws_vpc_security_group_egress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule)

**Resources:**
- `aws_security_group.bastion_east`, `aws_security_group.bastion_west` — bastion host security groups
- `aws_vpc_security_group_ingress_rule.bastion_east_ssh`, `aws_vpc_security_group_ingress_rule.bastion_west_ssh` — SSH ingress from `bastion_allowed_cidr`
- `aws_vpc_security_group_egress_rule.bastion_east_all`, `aws_vpc_security_group_egress_rule.bastion_west_all` — all outbound traffic allowed

**Outputs:**
- `bastion_east_sg_id`, `bastion_west_sg_id` — bastion security group IDs

---

### core-nat

Deploys [fck-nat](https://github.com/AndrewGuenther/fck-nat) instances as a cost-effective alternative to AWS managed NAT Gateways (~$1-2/mo vs ~$65/mo). Instances run as ARM64 spot instances (`t4g.nano`) with `persistent` stop behavior — they recover automatically after spot interruption without operator intervention. `source_dest_check = false` is required so the instance forwards packets between subnets.

AMIs are resolved at runtime from the official fck-nat AMI owner (`568608671756`) filtered by name `fck-nat-al2023-*` and architecture `arm64` — see [aws_ami data source docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami). AMI source: [github.com/AndrewGuenther/fck-nat](https://github.com/AndrewGuenther/fck-nat), docs: [fck-nat.dev](https://fck-nat.dev/stable/).

> **WARNING:** Depends on `core-subnets` (public subnet IDs), `core-routing` (private route table IDs), and `03-iam/bastion` (instance profile). Apply those modules before applying `core-nat`.

Destroy this module when no workloads in private subnets require internet access — NAT instances incur cost even when idle. Re-apply when needed.

**Resource types:** [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance), [aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) (data source), [aws_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)

**Resources:**
- `aws_instance.nat_east` — fck-nat ARM64 spot instance in `east-public-a`, `source_dest_check = false`
- `aws_instance.nat_west` — fck-nat ARM64 spot instance in `west-public-a`, `source_dest_check = false`
- `aws_route.east_private_to_nat` — `0.0.0.0/0` route in `rt-east-private` pointing to NAT east ENI
- `aws_route.west_private_to_nat` — `0.0.0.0/0` route in `rt-west-private` pointing to NAT west ENI

**Outputs:**
- `nat_east_instance_id`, `nat_west_instance_id` — NAT instance IDs
- `nat_east_eni_id`, `nat_west_eni_id` — NAT instance primary ENI IDs

**Health check**

Connect via SSM (requires [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)):

```bash
aws ssm start-session --target <instance-id> --region <region>
```

Once connected, verify NAT is functioning:

```bash
# Must be 1
cat /proc/sys/net/ipv4/ip_forward

# fck-nat runs as a one-shot service — inactive (dead) with status=0 is expected
sudo systemctl status fck-nat

# Must show MASQUERADE rule on ens5
sudo iptables -t nat -L POSTROUTING -n -v
```

---

### 03-iam

IAM resources shared across modules. Each sub-module groups roles and instance profiles by workload.

---

### bastion

Instance profile shared by bastion and NAT EC2 instances. Grants SSM Session Manager access (connect without SSH) and CloudWatch Logs access (ship system logs). No S3, KMS, or other permissions.

**Resource types:** [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role), [aws_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment), [aws_iam_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile)

**Resources:**
- `aws_iam_role.bastion` — EC2 trust policy
- `aws_iam_role_policy_attachment.bastion_ssm` — SSM Session Manager access
- `aws_iam_role_policy_attachment.bastion_cloudwatch` — CloudWatch Logs access
- `aws_iam_instance_profile.bastion` — instance profile attached to bastion EC2 instances

**Outputs:**
- `bastion_instance_profile_name` — instance profile name
- `bastion_instance_profile_arn` — instance profile ARN

---

### 04-vault

HashiCorp Vault for secrets management. Each sub-module groups resources by lifecycle layer.

---

### server

Deploys a single-node [HashiCorp Vault](https://developer.hashicorp.com/vault/docs) server in the east private subnet.

**Design decisions:**
- **Storage backend: S3** — Vault data persists in S3 and survives spot interruptions and instance termination. Raft (Integrated Storage) was considered but requires persistent local disk, which conflicts with spot instance usage.
- **Auto-unseal: KMS** — Vault unseals automatically on every restart without operator intervention. Required for spot instances to recover without manual involvement.
- **Instance type: `t3.micro` spot** — ~$2-3/mo. Sufficient for learning and dev workloads; Vault is lightweight at rest.
- **TLS disabled** — acceptable for dev since all access is via SSM port forwarding.
- **IAM role co-located** — Vault's KMS and S3 permissions are specific to this workload and not shared.

**Dependencies:**
- Apply `core-vpcs`, `core-subnets`, and `03-iam/bastion` before applying this module
- `core-nat` must be running — Vault is in a private subnet and requires outbound internet to reach KMS (auto-unseal) and S3 (storage); the SSM agent also requires internet to register with the SSM service

**Operational notes:**
- To save costs without losing Vault data, cancel the spot request from the AWS console instead of running `terraform destroy` — S3 data and KMS key remain intact; re-apply `core-nat` then `04-vault/server` to bring it back
- After `terraform destroy`, the KMS key enters a 7-day pending deletion window; re-applying within that window will fail due to alias conflict — delete the alias `alias/vault-unseal` from the AWS KMS console first
- Applying changes to `user_data` (e.g. this module) will cause Terraform to **replace the EC2 instance** — `user_data` is immutable on running instances. Vault data is safe: storage is in S3 and the unseal key is in KMS; the new instance will auto-unseal and resume normally
- On instance replacement, `vault operator init` is skipped automatically — Vault determines its initialized state by reading S3 on startup, so `user_data` only runs init if S3 contains no existing Vault data
- To fully re-initialize Vault from scratch (e.g. for testing), empty the S3 storage bucket before applying: `aws s3 rm s3://<vault-storage-bucket> --recursive --region us-east-1`; the `vault/init` secret will be overwritten automatically with the new credentials on first boot

**Production considerations:**
- Enable TLS by configuring `tls_cert_file` and `tls_key_file` in the Vault listener block
- Replace NAT with VPC endpoints for S3, KMS, and SSM — keeps traffic on the AWS network, removes the NAT dependency, better security posture; not used here as cost (~$7-10/mo each) exceeds the NAT instance for dev

**Resource types:** [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance), [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key), [aws_kms_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias), [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket), [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role), [aws_iam_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy), [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

**Resources:**
- `aws_kms_key.vault_unseal` — KMS key for auto-unseal, 7-day deletion window, annual key rotation enabled
- `aws_kms_alias.vault_unseal` — alias `alias/vault-unseal` for the unseal key
- `aws_s3_bucket.vault_storage` — storage backend (`vault-storage-<account-id>`), versioning enabled, KMS encrypted, public access blocked
- `aws_iam_role.vault` — EC2 trust policy
- `aws_iam_role_policy.vault_kms` — KMS encrypt/decrypt/describe/generate-data-key on the unseal key
- `aws_iam_role_policy.vault_s3` — get/put/delete/list on the storage bucket
- `aws_iam_role_policy_attachment.vault_ssm` — SSM Session Manager access
- `aws_iam_role_policy_attachment.vault_cloudwatch` — CloudWatch Logs access
- `aws_iam_instance_profile.vault` — instance profile attached to the Vault EC2 instance
- `aws_security_group.vault` — allows port 8200 inbound from east and west VPC CIDRs, all outbound
- `aws_instance.vault` — `t3.micro` spot instance running Vault, user data installs and configures Vault on first boot

**Outputs:**
- `vault_instance_id` — instance ID (used in SSM commands)
- `vault_private_ip` — private IP within the east VPC
- `vault_s3_bucket` — storage bucket name
- `vault_kms_key_arn` — KMS key ARN (used by the Vault config module)

**First-time initialization**

Vault initializes automatically on first boot. The `user_data` script waits for the API to be ready, checks S3 to confirm Vault is uninitialized, runs `vault operator init`, and stores the root token and recovery keys to Secrets Manager at `vault/init`.

To retrieve them after apply:

```bash
aws secretsmanager get-secret-value \
  --secret-id vault/init \
  --region us-east-1 \
  --query SecretString \
  --output text
```

The secret contains the full output of `vault operator init -format=json`: `root_token`, `recovery_keys_b64/hex`, and `recovery_keys_shares/threshold`. It is not needed for normal operations — KMS handles unsealing automatically on every restart. Retain it for two recovery scenarios: (1) the root token is lost and needs to be regenerated, (2) the KMS key is deleted or inaccessible and Vault cannot unseal.

**Connecting to Vault**

All access goes through SSM — no public IP or open firewall ports required.

```bash
# API access — use make targets (handle tunnel automatically):
make vault-status
make vault-bootstrap

# For other vault commands locally — run via vault-tunnel.sh:
./scripts/vault-tunnel.sh us-east-1 "vault secrets list"

# Direct shell on the server:
./scripts/vault-ssm-session.sh server
```

When using the CLI locally via tunnel:

```bash
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=$(aws secretsmanager get-secret-value \
  --secret-id vault/init \
  --region us-east-1 \
  --query SecretString \
  --output text | jq -r '.root_token')
vault secrets list

# UI
open http://localhost:8200/ui
```

**Health check**

```bash
# Via CLI
export VAULT_ADDR=http://localhost:8200
vault status

# On the instance
sudo systemctl status vault
```

---

### bootstrap

Configures Vault after initialization using the [Vault Terraform provider](https://registry.terraform.io/providers/hashicorp/vault/latest). Reads the root token from Secrets Manager and connects to Vault via the SSM tunnel established before apply.

**Dependencies:**
- `04-vault/server` must be applied and Vault must be fully initialized (secret at `vault/init` must exist)

Use `make vault-bootstrap` — it handles the SSM tunnel automatically.

**Providers:** AWS + [Vault](https://registry.terraform.io/providers/hashicorp/vault/latest) (`>=4.0.0`). The Vault provider authenticates with the root token read from Secrets Manager at plan/apply time.

**Resource types:** [vault_mount](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount), [vault_auth_backend](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/auth_backend), [vault_policy](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy), [aws_ssm_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter)

**Resources (`vault_east.tf`):**
- `vault_mount.kv` — KV v2 secrets engine at path `secret/`
- `vault_auth_backend.approle` — AppRole authentication method
- `vault_auth_backend.aws` — AWS IAM authentication method
- `vault_policy.admin` — full access to all paths (`*`)
- `vault_policy.read_only` — read-only access to `secret/data/*` and `secret/metadata/*`

**Outputs:**
- `kv_mount_path` — KV v2 mount path (`secret`)
- `approle_accessor` — AppRole auth accessor ID
- `aws_auth_accessor` — AWS auth accessor ID

---

### client

EC2 instance in the east private subnet with the Vault CLI pre-installed. Provides an interactive shell for running Vault commands without requiring a local SSM port-forwarding tunnel — connect via SSM Session Manager, source `/etc/profile.d/vault.sh`, and the CLI is ready to use.

**Dependencies:**
- Apply `core-vpcs`, `core-subnets`, and `03-iam/bastion` before applying this module
- `04-vault/server` must be applied — the client reads the Vault server's private IP from SSM at boot time to configure `VAULT_ADDR`
- `core-nat` must be running — the instance is in a private subnet and requires outbound internet to install packages and register with SSM

**Resource types:** [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance), [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group), [aws_vpc_security_group_egress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule), [aws_ssm_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter)

**Resources:**
- `aws_instance.vault_client` — `t3.micro` spot instance; user data installs Vault CLI, writes `VAULT_ADDR` to `/etc/profile.d/vault.sh` by reading the server's private IP from SSM, and pre-creates `/etc/sudoers.d/ssm-agent-users` to grant ssm-user passwordless sudo
- `aws_security_group.vault_client` — egress-only; no inbound rules required (SSM Session Manager uses outbound connections)
- `aws_vpc_security_group_egress_rule.vault_client_all` — all outbound traffic allowed
- `aws_ssm_parameter.instance_id` — publishes instance ID to `/tf/aws-infra/vault/client/instance-id`

**Outputs:**
- `instance_id` — instance ID

**Connecting**

```bash
./scripts/vault-ssm-session.sh client

# Source environment to set VAULT_ADDR — run once after connecting:
source /etc/profile.d/vault.sh
vault login
vault secrets list
```

---

## New Module Bootstrap

Copy files from `module_skel/` into the new module directory and replace the `<module-path>` placeholders in `locals.tf` and `terraform.tf` with the module's relative path (e.g. `02-networking/core-vpcs`).

**Variable defaults:** All variables across all modules have defaults. No `terraform.tfvars` files are used — this is a demo project and the defaults reflect the intended configuration. Override via `-var` on the CLI if needed.

**File naming convention for resource files:**

- Single-region modules: suffix resource files with `_east` (e.g. `ec2_east.tf`, `iam_east.tf`). This makes it clear at a glance which region the resources target.
- Multi-region modules: use `_east` and `_west` suffixes to split resources by region (e.g. `subnets_east.tf`, `subnets_west.tf`). One file per region per resource type.
- `main.tf` contains only `data` blocks (remote state lookups, AMI lookups, etc.) — no managed resources.
- Shared files with no region scope (`locals.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) carry no suffix.

**Cross-module data sharing:**

Modules pass values to each other via Terraform remote state — downstream modules declare a `data "terraform_remote_state"` block in `main.tf` and reference outputs from upstream modules through `locals.tf`. This is the primary mechanism for inter-module communication within Terraform.

For consumers outside the Terraform ecosystem (scripts, CI pipelines, application config), key outputs are also published to SSM Parameter Store. Paths follow the directory structure of the repo, stripping the numeric prefix:

```
/tf/aws-infra/<category>/<module>/<key>
```

| Category | Maps to |
|---|---|
| `networking` | `02-networking/` |
| `iam` | `03-iam/` |
| `vault` | `04-vault/` |

Examples:
```
/tf/aws-infra/networking/core-vpcs/vpc-id
/tf/aws-infra/iam/bastion/instance-profile-arn
/tf/aws-infra/vault/server/instance-id
/tf/aws-infra/vault/bootstrap/kv-mount-path
```

These parameters are region-scoped — querying the same path in `us-east-1` vs `us-west-1` returns the respective region's value. The hierarchy lets you query all parameters for a category or module with a single `get-parameters-by-path` call, e.g. `aws ssm get-parameters-by-path --path /tf/aws-infra/vault/ --recursive`. Add an `ssm_east.tf` / `ssm_west.tf` to any new module that produces values other tooling may need.

---

## Diagrams

### Network Resources Diagram

Shows the combined resources of `02-networking/core-vpcs`, `02-networking/core-subnets`, `02-networking/core-routing`, and `02-networking/core-nat`. The two regions are connected via VPC peering `pcx-east-to-west`, shown as a dashed line at the boundary of each diagram.

**us-east-1**

```mermaid
graph TD
    INET((Internet))

    subgraph east["us-east-1"]
        IGW_E[igw-east]
        VPC_E["vpc-east · 10.1.0.0/16"]
        RT_E_PUB[rt-east-public]
        RT_E_PRI[rt-east-private]
        PUB_E_A["east-public-a · 10.1.0.0/24"]
        PUB_E_B["east-public-b · 10.1.1.0/24"]
        NAT_E[fck-nat-east]
        PRI_E_A["east-private-a · 10.1.10.0/24"]
        PRI_E_B["east-private-b · 10.1.11.0/24"]
        DB_E_A["east-db-a · 10.1.20.0/24"]
        DB_E_B["east-db-b · 10.1.21.0/24"]
    end

    PCX([pcx-east-to-west])

    INET --> IGW_E
    IGW_E --- VPC_E
    VPC_E --- RT_E_PUB & RT_E_PRI
    RT_E_PUB --> PUB_E_A & PUB_E_B
    PUB_E_A --- NAT_E
    RT_E_PRI --> PRI_E_A & PRI_E_B
    PRI_E_A & PRI_E_B --> NAT_E
    VPC_E --- DB_E_A & DB_E_B
    VPC_E -.- PCX
```

**us-west-1**

```mermaid
graph TD
    PCX([pcx-east-to-west])

    subgraph west["us-west-1"]
        IGW_W[igw-west]
        VPC_W["vpc-west · 10.10.0.0/16"]
        RT_W_PUB[rt-west-public]
        RT_W_PRI[rt-west-private]
        PUB_W_A["west-public-a · 10.10.0.0/24"]
        PUB_W_B["west-public-b · 10.10.1.0/24"]
        NAT_W[fck-nat-west]
        PRI_W_A["west-private-a · 10.10.10.0/24"]
        PRI_W_B["west-private-b · 10.10.11.0/24"]
        DB_W_A["west-db-a · 10.10.20.0/24"]
        DB_W_B["west-db-b · 10.10.21.0/24"]
    end

    PCX -.- VPC_W
    INET((Internet)) --> IGW_W
    IGW_W --- VPC_W
    VPC_W --- RT_W_PUB & RT_W_PRI
    RT_W_PUB --> PUB_W_A & PUB_W_B
    PUB_W_A --- NAT_W
    RT_W_PRI --> PRI_W_A & PRI_W_B
    PRI_W_A & PRI_W_B --> NAT_W
    VPC_W --- DB_W_A & DB_W_B
```

---

### Vault Resources Diagram

Shows the `04-vault/server` resources: the Vault EC2 instance in the private subnet, outbound connectivity via NAT to AWS services, and operator access via SSM port forwarding.

```mermaid
graph TD
    subgraph pri["vpc-east · private subnet"]
        EC2[vault-server]
    end

    subgraph pub["vpc-east · public subnet"]
        NAT[fck-nat-east]
    end

    REPO["HashiCorp RPM repo\nrpm.releases.hashicorp.com"]
    S3[("S3 · vault-storage-&lt;account-id&gt;")]
    KMS["KMS · alias/vault-unseal"]
    SM["Secrets Manager · vault/init"]
    SSM((SSM))
    OPS((operator))
    INET(("Internet\nAWS public endpoints"))

    EC2 -->|outbound via default route| NAT
    NAT -->|no VPC endpoints - traffic exits to internet| INET
    INET -->|"install vault package (first boot)"| REPO
    INET -->|storage backend| S3
    INET -->|auto-unseal| KMS
    INET -->|write init credentials| SM
    INET -->|SSM agent keeps persistent\noutbound connection| SSM
    OPS -->|"ssm port-forward :8200"| SSM
    SSM -. "tunnel · exposes :8200 on localhost\nso Terraform Vault provider can connect" .-> EC2
```

---

### Vault Client Diagram

Shows `04-vault/client`: the vault-client instance in the east private subnet, outbound connectivity via NAT for package installs and SSM registration, and operator access via interactive SSM shell. The client connects to vault-server directly over the private network.

```mermaid
graph TD
    subgraph pri["vpc-east · private subnet"]
        CLIENT[vault-client]
        SERVER[vault-server]
    end

    subgraph pub["vpc-east · public subnet"]
        NAT[fck-nat-east]
    end

    REPO["HashiCorp RPM repo"]
    SSM((SSM))
    OPS((operator))
    INET(("Internet\nAWS public endpoints"))

    CLIENT -->|outbound via default route| NAT
    NAT --> INET
    INET -->|"install vault package (first boot)"| REPO
    INET -->|SSM agent| SSM
    OPS -->|"vault-ssm-session.sh client"| SSM
    SSM -. "interactive shell" .-> CLIENT
    CLIENT -->|"port 8200 · VAULT_ADDR"| SERVER
```
