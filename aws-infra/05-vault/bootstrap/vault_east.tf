resource "vault_mount" "kv" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV v2 secrets engine"
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_auth_backend" "aws" {
  type = "aws"
}

resource "vault_policy" "admin" {
  name = "admin"

  policy = <<-HCL
    path "*" {
      capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    }
  HCL
}

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
