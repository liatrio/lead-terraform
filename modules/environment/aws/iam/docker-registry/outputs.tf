output "docker_registry_aws_access_key_id" {
  value = aws_iam_access_key.docker_registry.id
}

output "docker_registry_aws_secret_access_key" {
  value     = aws_iam_access_key.docker_registry.secret
  sensitive = true
}

output "docker_registry_s3_bucket_name" {
  value = aws_s3_bucket.docker_registry.bucket
}
