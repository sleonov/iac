# KV v2 secrets engine — versioned key/value store for application secrets
resource "vault_mount" "kv" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV v2 secrets engine"
}

# AppRole auth — application-facing; apps exchange a role_id + secret_id for a Vault token
resource "vault_auth_backend" "approle" {
  type = "approle"
}

# AWS auth — lets EC2 instances and Lambda functions authenticate using their IAM identity
resource "vault_auth_backend" "aws" {
  type = "aws"
}

# admin policy — full access to all paths; intended for operators and Terraform runs
resource "vault_policy" "admin" {
  name = "admin"

  policy = <<-HCL
    path "*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
  HCL
}

# read-only policy — scoped read access to the KV store; intended for applications
resource "vault_policy" "read_only" {
  name = "read-only"

  policy = <<-HCL
    path "secret/data/*" {
      capabilities = ["read", "list"]
    }
    path "secret/metadata/*" {
      capabilities = ["read", "list"]
    }
  HCL
}
