output "iam_user_arn" {
  value = aws_iam_user.ses_smtp.arn
}

output "iam_user_name" {
  value = aws_iam_user.ses_smtp.name
}

output "smtp_username" {
  value = aws_iam_access_key.ses_smtp.id
}

output "smtp_password" {
  value       = aws_iam_access_key.ses_smtp.ses_smtp_password_v4
  sensitive   = true
}
