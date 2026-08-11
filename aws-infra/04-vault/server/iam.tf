resource "aws_iam_role" "vault" {
  name = "vault-server"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vault_kms" {
  name = "vault-kms-unseal"
  role = aws_iam_role.vault.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "kms:Encrypt",         # seal: encrypt Vault's master key before writing to storage
        "kms:Decrypt",         # unseal: decrypt the master key on startup
        "kms:DescribeKey",     # verify the key exists and is enabled before use
        "kms:GenerateDataKey"  # generate the data key used to encrypt Vault's barrier during init
      ]
      Resource = aws_kms_key.vault_unseal.arn
    }]
  })
}

resource "aws_iam_role_policy" "vault_s3" {
  name = "vault-s3-storage"
  role = aws_iam_role.vault.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",    # read secrets and Vault data from storage
        "s3:PutObject",    # write secrets and Vault data to storage
        "s3:DeleteObject", # remove expired tokens, leases, and revoked secrets
        "s3:ListBucket"    # enumerate keys during startup and compaction
      ]
      Resource = [
        aws_s3_bucket.vault_storage.arn,
        "${aws_s3_bucket.vault_storage.arn}/*"
      ]
    }]
  })
}

# Allows connecting to the instance via AWS SSM Session Manager without SSH
resource "aws_iam_role_policy_attachment" "vault_ssm" {
  role       = aws_iam_role.vault.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Allows the CloudWatch agent to ship system and Vault audit logs
resource "aws_iam_role_policy_attachment" "vault_cloudwatch" {
  role       = aws_iam_role.vault.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "vault" {
  name = "vault-server"
  role = aws_iam_role.vault.name
}
