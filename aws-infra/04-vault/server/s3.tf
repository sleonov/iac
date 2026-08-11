# Vault storage backend — persists all encrypted Vault data (secrets, tokens, policies).
# Account ID suffix ensures a globally unique, predictable name across apply/destroy cycles.
resource "aws_s3_bucket" "vault_storage" {
  bucket = "vault-storage-${data.aws_caller_identity.current.account_id}"
}

# Versioning allows recovery from accidental overwrites or corruption of Vault data
resource "aws_s3_bucket_versioning" "vault_storage" {
  bucket = aws_s3_bucket.vault_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt bucket contents with the same KMS key used for auto-unseal — adds a second layer
# on top of Vault's own encryption of stored data
resource "aws_s3_bucket_server_side_encryption_configuration" "vault_storage" {
  bucket = aws_s3_bucket.vault_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.vault_unseal.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "vault_storage" {
  bucket                  = aws_s3_bucket.vault_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
