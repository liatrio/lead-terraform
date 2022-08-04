#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "velero" {
  bucket = "velero-${var.account_id}-${var.cluster_name}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "velero_encryption" {
  bucket = aws_s3_bucket.velero.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.velero_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "velero_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_logging" "velero_logging" {
  bucket = aws_s3_bucket.velero.id

  target_bucket = var.s3_logging_id
  target_prefix = "VeleroLogs/"
}

# Used to restrict public access and block users from creating policies to enable it
resource "aws_s3_bucket_public_access_block" "velero_block" {
  bucket                  = aws_s3_bucket.velero.id
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_policy     = true
}

resource "aws_s3_bucket_acl" "velero_acl" {
  bucket = aws_s3_bucket.velero.id
  acl    = "private"
}
