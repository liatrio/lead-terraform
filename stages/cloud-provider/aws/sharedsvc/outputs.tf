output "cluster_id" {
  value = module.eks.cluster_id
}

output "essential_taint_key" {
  value = var.essential_taint_key
}

output "eks_openid_connect_provider_arn" {
  value = module.eks.aws_iam_openid_connect_provider_arn
}

output "eks_openid_connect_provider_url" {
  value = module.eks.aws_iam_openid_connect_provider_url
}

output "vault_aws_access_key_id" {
  value = aws_iam_access_key.vault.id
}

output "vault_aws_secret_access_key" {
  value     = aws_iam_access_key.vault.secret
  sensitive = true
}

output "vault_dynamodb_table_name" {
  value = aws_dynamodb_table.vault_dynamodb_storage.name
}

output "vault_kms_key_id" {
  value = aws_kms_key.vault_seal_key.id
}

output "cluster_autoscaler_service_account_arn" {
  value = module.cluster_autoscaler_iam.cluster_autoscaler_service_account_arn
}
output "external_dns_service_account_arn" {
  value = module.external_dns_iam.external_dns_service_account_arn
}

output "external_dns_public_service_account_arn" {
  value = module.external_dns_iam_public.external_dns_service_account_arn
}

output "cert_manager_service_account_arn" {
  value = module.cert_manager_iam.cert_manager_service_account_arn
}

output "docker_registry_aws_access_key_id" {
  value = module.docker_registry_iam.docker_registry_aws_access_key_id
}

output "docker_registry_aws_secret_access_key" {
  value     = module.docker_registry_iam.docker_registry_aws_secret_access_key
  sensitive = true
}

output "docker_registry_s3_bucket_name" {
  value = module.docker_registry_iam.docker_registry_s3_bucket_name
}

output "github_runners_service_account_arn" {
  value = module.github-runners-s3.github_runners_service_account_arn
}

output "lead_environments_pipeline_service_account_arn" {
  value = module.lead_environments_pipeline_iam.role_arn
}

output "lead_terraform_pipeline_service_account_arn" {
  value = module.lead_terraform_pipeline_iam.role_arn
}

output "atlantis_service_account_arn" {
  value = aws_iam_role.atlantis_service_account.arn
}
