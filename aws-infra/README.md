## AWS infra setup

> **NOTE:**
> - This document describes the bootstrap of a sample AWS infrastructure using Terraform.
> - Requires Terraform ≥1.10 and AWS provider ≥6.34.0.
> - AWS authentication relies on the `AWS_PROFILE` environment variable — ensure it is set before running any Terraform commands, e.g. `export AWS_PROFILE=<your-profile>`.

## Table of Contents

- [Provider](#provider)
- [Remote State](#remote-state)
- [New Module Bootstrap](#new-module-bootstrap)
- [01-bootstrap](#01-bootstrap)
- [02-networking](#02-networking)
  - [core-vpcs](#core-vpcs)
  - [core-subnets](#core-subnets)
  - [core-routing](#core-routing)
  - [core-security-groups](#core-security-groups)
  - [core-nat](#core-nat)
  - [Network Resources Diagram](#network-resources-diagram)
- [03-iam](#03-iam)
  - [bastion](#bastion)

## Provider

All modules use the [AWS Terraform provider](https://registry.terraform.io/providers/hashicorp/aws/latest) (`hashicorp/aws`). The provider translates Terraform resource definitions into AWS API calls, managing the full lifecycle of AWS resources (create, read, update, delete).

- [Registry page](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub](https://github.com/hashicorp/terraform-provider-aws)

## Remote State

All modules store state in S3 bucket `terraform-state-607527010331`. It is created in `01-bootstrap` step, using local state.

| Module                              | State key                                                         |
|-------------------------------------|-------------------------------------------------------------------|
| 02-networking/core-vpcs             | `aws-infra/02-networking/core-vpcs/terraform.tfstate`             |
| 02-networking/core-subnets          | `aws-infra/02-networking/core-subnets/terraform.tfstate`          |
| 02-networking/core-routing          | `aws-infra/02-networking/core-routing/terraform.tfstate`          |
| 02-networking/core-security-groups  | `aws-infra/02-networking/core-security-groups/terraform.tfstate`  |
| 02-networking/core-nat              | `aws-infra/02-networking/core-nat/terraform.tfstate`              |
| 03-iam/bastion                      | `aws-infra/03-iam/bastion/terraform.tfstate`                      |
| 03-vault                            | `aws-infra/03-vault/terraform.tfstate`                            |

## New Module Bootstrap

Copy files from `module_skel/` into the new module directory and replace the `<module-path>` placeholders in `locals.tf` and `terraform.tf` with the module's relative path (e.g. `02-networking/core-vpcs`).

## 01-bootstrap

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

## 02-networking

Creates resources in east and west regions for core networking infrastructure.

### core-vpcs

**Resource types:** [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)

**Resources:**
- `aws_vpc.east` — east VPC (`us-east-1`) with DNS support enabled
- `aws_vpc.west` — west VPC (`us-west-1`) with DNS support enabled

**Outputs:**
- `east_vpc_id`, `west_vpc_id` — VPC IDs
- `east_vpc_cidr`, `west_vpc_cidr` — VPC CIDR blocks

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

### core-security-groups

VPC IDs are retrieved from `core-vpcs` remote state. SSH ingress is restricted to `bastion_allowed_cidr` — set this to your public IP in `terraform.tfvars`.

**Resource types:** [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group), [aws_vpc_security_group_ingress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule), [aws_vpc_security_group_egress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule)

**Resources:**
- `aws_security_group.bastion_east`, `aws_security_group.bastion_west` — bastion host security groups
- `aws_vpc_security_group_ingress_rule.bastion_east_ssh`, `aws_vpc_security_group_ingress_rule.bastion_west_ssh` — SSH ingress from `bastion_allowed_cidr`
- `aws_vpc_security_group_egress_rule.bastion_east_all`, `aws_vpc_security_group_egress_rule.bastion_west_all` — all outbound traffic allowed

**Outputs:**
- `bastion_east_sg_id`, `bastion_west_sg_id` — bastion security group IDs

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

### Network Resources Diagram

Shows the combined resources of `core-vpcs`, `core-subnets`, `core-routing`, and `core-nat`. The two regions are connected via VPC peering `pcx-east-to-west`, shown as a dashed line at the boundary of each diagram.

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

## 03-iam

IAM resources shared across modules. Each sub-module groups roles and instance profiles by workload.

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
