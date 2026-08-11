resource "aws_instance" "vault" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.vault.name
  vpc_security_group_ids = [aws_security_group.vault.id]

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "stop"
      spot_instance_type             = "persistent"
    }
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
  }

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail

    # Install Vault from HashiCorp repo
    yum install -y yum-utils
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    yum install -y vault

    # Write Vault configuration
    cat > /etc/vault.d/vault.hcl <<EOF
    ui = true

    storage "s3" {
      bucket = "${aws_s3_bucket.vault_storage.id}"
      region = "${var.region}"
    }

    seal "awskms" {
      region     = "${var.region}"
      kms_key_id = "${aws_kms_key.vault_unseal.key_id}"
    }

    listener "tcp" {
      address     = "0.0.0.0:8200"
      # WARNING: TLS is disabled — Vault API traffic is unencrypted.
      # Acceptable for dev/learning since access is via SSM port forwarding only.
      # In production: remove tls_disable and configure tls_cert_file/tls_key_file.
      tls_disable = true
    }
    EOF

    systemctl enable vault
    systemctl start vault

    # Auto-initialize Vault on first boot
    export VAULT_ADDR="http://127.0.0.1:8200"

    # Wait for Vault API to be ready (KMS auto-unseal happens automatically)
    until vault status > /dev/null 2>&1; do
      sleep 2
    done

    # Only initialize if not already initialized (idempotent across reboots)
    if vault status -format=json | python3 -c "import sys,json; sys.exit(0 if not json.load(sys.stdin)['initialized'] else 1)" 2>/dev/null; then
      INIT_OUTPUT=$(vault operator init -format=json)
      aws secretsmanager put-secret-value \
        --region "${var.region}" \
        --secret-id "${aws_secretsmanager_secret.vault_init.arn}" \
        --secret-string "$INIT_OUTPUT"
    fi
  EOT

  tags = {
    Name = "vault-server"
  }
}
