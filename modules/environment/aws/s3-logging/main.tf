#tfsec:ignore:aws-s3-enable-bucket-logging
#tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "s3_logging" {
  bucket = "s3-logging-${var.account_id}-${var.cluster_name}"
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_logging_encryption" {
  bucket = aws_s3_bucket.s3_logging.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_logging_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "s3_logging_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# Used to restrict public access and block users from creating policies to enable it
resource "aws_s3_bucket_public_access_block" "s3_logging_block" {
  bucket                  = aws_s3_bucket.s3_logging.id
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_policy     = true
}

resource "aws_s3_bucket_acl" "s3_logging_acl" {
  bucket = aws_s3_bucket.s3_logging.id
  acl    = "private"
}
