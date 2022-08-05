output "cluster_name" {
  value = module.eks.cluster_id
}

output "root_zone_name" {
  value = var.root_zone_name
}

output "essential_taint_key" {
  value = var.essential_taint_key
}

output "elb_security_group_id" {
  value = module.eks.aws_security_group_elb.id
}

output "eks_openid_connect_provider_arn" {
  value = module.eks.aws_iam_openid_connect_provider_arn
}

output "eks_openid_connect_provider_url" {
  value = module.eks.aws_iam_openid_connect_provider_url
}

output "workspace_iam_role_name" {
  value = module.eks.workspace_iam_role.name
}

output "cluster_zone_id" {
  value       = aws_route53_zone.cluster_zone.zone_id
  description = "Route53 zone id for EKS cluster; passed as input to app stage"
}

output "vcluster_zone_id" {
  value       = var.enable_vcluster ? aws_route53_zone.vcluster[0].zone_id : ""
  description = "Route53 zone id for vclusters running within the EKS cluster; passed as input to app stage"
}

output "external_dns_service_account_arn" {
  value = module.external_dns_iam.external_dns_service_account_arn
}

output "cert_manager_service_account_arn" {
  value = module.cert_manager_iam.cert_manager_service_account_arn
}

output "cluster_autoscaler_service_account_arn" {
  value = module.cluster_autoscaler_iam.cluster_autoscaler_service_account_arn
}

output "codeservices_sqs_url" {
  value = try(module.codeservices[0].sqs_url, "")
}

output "sparky_service_account_arn" {
  value = aws_iam_role.sparky_service_account.arn
}

output "product_operator_service_account_arn" {
  value = aws_iam_role.product_operator_service_account.arn
}

output "github_runners_service_account_arn" {
  value = module.github-runners.github_runners_service_account_arn
}

output "codeservices_event_mapper_service_account_arn" {
  value = try(module.codeservices[0].event_mapper_role_arn, "")
}

output "codeservices_s3_bucket" {
  value = try(module.codeservices[0].s3_bucket, "")
}

output "codeservices_codebuild_role" {
  value = try(module.codeservices[0].codebuild_role, "")
}

output "codeservices_pipeline_role" {
  value = try(module.codeservices[0].codepipeline_role, "")
}

output "codeservices_codebuild_security_group_id" {
  value = try(module.codeservices[0].codebuild_security_group_id, "")
}

output "vault_service_account_arn" {
  value = aws_iam_role.vault_service_account.arn
}

output "vault_dynamodb_table_name" {
  value = aws_dynamodb_table.vault_dynamodb_storage.name
}

output "vault_kms_key_id" {
  value = aws_kms_key.vault_seal_key.key_id
}

output "velero_service_account_arn" {
  value = var.enable_velero ? module.velero_iam[0].velero_service_account_arn : ""
}

output "s3_logging_id" {
  value = module.s3-logging.s3_logging_bucket_id
}
