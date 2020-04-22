output "cluster_autoscaler_service_account_arn" {
  value = aws_iam_role.cluster_autoscaler_service_account.arn
}
