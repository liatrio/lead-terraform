#tfsec:ignore:aws-s3-specify-public-access-block
#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-encryption
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "velero" {
  bucket = "velero-${var.account_id}-${var.cluster_name}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}
