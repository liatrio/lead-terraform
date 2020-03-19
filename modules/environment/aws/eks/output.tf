output "cluster_id" {
  value = module.eks.cluster_id
}

output "aws_iam_openid_connect_provider" {
  value = aws_iam_openid_connect_provider.default
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "workspace_iam_role" {
  value = aws_iam_role.workspace_role
}

output "aws_security_group_elb" {
  value = aws_security_group.elb
}
