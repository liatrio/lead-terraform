resource "aws_s3_bucket" "velero" {
  bucket = "velero-${var.account_id}-${var.cluster_name}"
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}
