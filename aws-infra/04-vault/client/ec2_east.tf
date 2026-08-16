resource "aws_instance" "vault_client" {
  provider               = aws.east
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_id
  iam_instance_profile   = local.instance_profile_name
  vpc_security_group_ids = [aws_security_group.vault_client.id]

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "stop"
      spot_instance_type             = "persistent"
    }
  }

  user_data_replace_on_change = true

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted   = true
  }

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail

    # Install Vault CLI from HashiCorp repo
    yum install -y yum-utils
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    yum install -y vault

    # Read Vault server private IP from SSM and write to /etc/profile.d so
    # VAULT_ADDR is available after running: source /etc/profile.d/vault.sh
    VAULT_IP=$(aws ssm get-parameter \
      --region ${var.east_region} \
      --name /tf/aws-infra/vault/server/private-ip \
      --query Parameter.Value \
      --output text)

    echo "export VAULT_ADDR=http://$VAULT_IP:8200" > /etc/profile.d/vault.sh

    printf '# User rules for ssm-user\nssm-user ALL=(ALL) NOPASSWD:ALL\n' \
      > /etc/sudoers.d/ssm-agent-users
    chmod 440 /etc/sudoers.d/ssm-agent-users
  EOT

  tags = {
    Name       = "vault-client"
    manage-r53-record = ""
  }
}
