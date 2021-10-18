output "github_runners_service_account_arn" {
  value       = var.iam_role_name == "" ? aws_iam_role.github_runners_service_account[0].arn : data.aws_iam_role.iam_role[0].arn
  description = "Runner IAM Role"
}
