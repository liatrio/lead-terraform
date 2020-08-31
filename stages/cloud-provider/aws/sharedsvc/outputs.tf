output "cluster_id" {
  value = module.eks.cluster_id
}

output "essential_taint_key" {
  value = var.essential_taint_key
}

output "eks_openid_connect_provider_arn" {
  value = module.eks.aws_iam_openid_connect_provider.arn
}

output "eks_openid_connect_provider_url" {
  value = module.eks.aws_iam_openid_connect_provider.url
}
