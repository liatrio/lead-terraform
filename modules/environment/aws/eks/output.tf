output "cluster_id" {
  value = module.eks.cluster_id
}

output "worker_autoscaling_policy_arn" {
  value = module.eks.worker_autoscaling_policy_arn
}

output "aws_iam_openid_connect_provider" {
  value = aws_iam_openid_connect_provider.default
}

output "workspace_iam_role" {
  value = aws_iam_role.workspace_role
}

output "aws_security_group_elb" {
  value = aws_security_group.elb
}