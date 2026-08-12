# Targets are independent — run them individually in the order documented in README.md.
# Apply order: core-vpcs → core-subnets → core-routing → core-security-groups → iam-bastion → core-nat → vault-server → vault-bootstrap → vault-client
# Requires AWS_PROFILE to be set: export AWS_PROFILE=<your-profile>

AWS_REGION ?= us-east-1
# DESTROY=1 switches terraform apply to terraform destroy for any target:
#   make vault-server            # apply
#   make vault-server DESTROY=1  # destroy
#   make core-nat DESTROY=1      # destroy core-nat only
TF_COMMAND   = $(if $(DESTROY),destroy -auto-approve,$(if $(PLAN),plan,apply -auto-approve))

# terraform init runs before every target — idempotent, safe to re-run, ensures providers
# are installed on a fresh clone without requiring a separate init step

.DEFAULT_GOAL := help

.PHONY: help core-vpcs core-subnets core-routing core-security-groups core-nat core-nat-status \
	iam-bastion vault-server vault-bootstrap vault-status vault-client

help:
	@echo "Usage: make <target> [DESTROY=1] [AWS_REGION=us-east-1]"
	@echo ""
	@echo "Targets:"
	@echo "  core-vpcs            02-networking/core-vpcs"
	@echo "  core-subnets         02-networking/core-subnets"
	@echo "  core-routing         02-networking/core-routing"
	@echo "  core-security-groups 02-networking/core-security-groups"
	@echo "  core-nat             02-networking/core-nat"
	@echo "  core-nat-status      check NAT instance iptables and service status via SSM"
	@echo "  iam-bastion          03-iam/bastion"
	@echo "  vault-server         04-vault/server"
	@echo "  vault-bootstrap      04-vault/bootstrap  (manages SSM tunnel automatically)"
	@echo "  vault-status         run vault status via SSM tunnel"
	@echo "  vault-client         04-vault/client"
	@echo ""
	@echo "Examples:"
	@echo "  make vault-server"
	@echo "  make vault-server DESTROY=1"

core-vpcs:
	cd 02-networking/core-vpcs && terraform init && terraform $(TF_COMMAND)

core-subnets:
	cd 02-networking/core-subnets && terraform init && terraform $(TF_COMMAND)

core-routing:
	cd 02-networking/core-routing && terraform init && terraform $(TF_COMMAND)

core-security-groups:
	cd 02-networking/core-security-groups && terraform init && terraform $(TF_COMMAND)

core-nat:
	cd 02-networking/core-nat && terraform init && terraform $(TF_COMMAND)

# core-nat-status: runs fck-nat service status and iptables check via scripts/ssm-run.sh
core-nat-status:
	@scripts/ssm-run.sh $(AWS_REGION) /tf/aws-infra/networking/core-nat/instance-id \
		"systemctl status fck-nat" \
		"iptables -t nat -L POSTROUTING -n -v"

iam-bastion:
	cd 03-iam/bastion && terraform init && terraform $(TF_COMMAND)

vault-server:
	cd 04-vault/server && terraform init && terraform $(TF_COMMAND)

# vault-bootstrap: tunnel setup/teardown is handled by scripts/vault-tunnel.sh
vault-bootstrap:
	@scripts/vault-tunnel.sh $(AWS_REGION) "cd 04-vault/bootstrap && terraform init && terraform $(TF_COMMAND)"

# vault-status: tunnel setup/teardown is handled by scripts/vault-tunnel.sh
vault-status:
	@scripts/vault-tunnel.sh $(AWS_REGION) "VAULT_ADDR=http://127.0.0.1:8200 vault status"

vault-client:
	cd 04-vault/client && terraform init && terraform $(TF_COMMAND)
