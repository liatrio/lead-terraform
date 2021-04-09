output "github_runners_service_account_arn" {
  value       = aws_iam_role.github_runners_service_account.arn
  description = "Runner IAM Role"
}
