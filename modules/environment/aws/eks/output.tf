output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_asg_names" {
  value = module.eks.eks_managed_node_groups_autoscaling_group_names
}

output "aws_iam_openid_connect_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "aws_iam_openid_connect_provider_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "workspace_iam_role" {
  value = aws_iam_role.workspace_role
}

output "aws_security_group_elb" {
  value = aws_security_group.elb
}

output "vpc_id" {
  value = data.aws_vpc.lead_vpc.id
}
