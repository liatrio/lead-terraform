output "cluster_id" {
  value = module.eks.cluster_id
}

output "kubeconfig" {
  value = "${path.cwd}/kubeconfig_${module.eks.cluster_id}"
}

output "aws_iam_openid_connect_provider" {
  value = module.eks.aws_iam_openid_connect_provider
}