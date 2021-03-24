output "velero_bucket_name" {
  value = length(aws_s3_bucket.velero) > 0 ? aws_s3_bucket.velero.0.bucket : ""
}

output "velero_aws_secret_access_key" {
  value = length(aws_iam_access_key.velero) > 0 ? aws_iam_access_key.velero.0.secret : ""
}

output "velero_aws_access_key_id" {
  value = length(aws_iam_access_key.velero) > 0 ? aws_iam_access_key.velero.0.id : ""
}
