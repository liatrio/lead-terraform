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
  value = module.eks.aws_iam_openid_connect_provider.arn
}

output "eks_openid_connect_provider_url" {
  value = module.eks.aws_iam_openid_connect_provider.url
}

output "workspace_iam_role_name" {
  value = module.eks.workspace_iam_role.name
}

output "cluster_zone_id" {
  value = aws_route53_zone.cluster_zone.zone_id
  description = "Route53 zone id for EKS cluster; passed as input to app stage"
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
  value = module.codeservices.sqs_url
}

output "operator_slack_service_account_arn" {
  value = aws_iam_role.operator_slack_service_account.arn
}

output "operator_jenkins_service_account_arn" {
  value = aws_iam_role.operator_jenkins_service_account.arn
}

output "product_operator_service_account_arn" {
  value = aws_iam_role.product_operator_service_account.arn
}

output "rode_service_account_arn" {
  value = aws_iam_role.rode_service_account.arn
}

output "codeservices_event_mapper_service_account_arn" {
  value = module.codeservices.event_mapper_role_arn
}

output "codeservices_s3_bucket" {
  value = module.codeservices.s3_bucket
}

output "codeservices_codebuild_role" {
  value = module.codeservices.codebuild_role
}

output "codeservices_pipeline_role" {
  value = module.codeservices.codepipeline_role
}

output "codeservices_codebuild_security_group_id" {
  value = module.codeservices.codebuild_security_group_id
}

output "vault_aws_access_key_id" {
  value = aws_iam_access_key.vault-test.id
}

output "vault_aws_secret_access_key" {
  value = aws_iam_access_key.vault-test.secret
}

output "vault_dynamodb_table_name" {
  value = aws_dynamodb_table.vault_dynamodb_storage.name
}

output "vault_kms_key_id" {
  value = aws_kms_key.vault_seal_key.key_id
}
