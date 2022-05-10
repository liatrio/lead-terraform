output "s3_bucket" {
  value = length(aws_s3_bucket.code_services_bucket) > 0 ? aws_s3_bucket.code_services_bucket.id : ""
}

output "codebuild_role" {
  value = length(aws_iam_role.codebuild_role) > 0 ? aws_iam_role.codebuild_role.arn : ""
}

output "codebuild_security_group_id" {
  value = length(aws_security_group.codebuild_security_group) > 0 ? aws_security_group.codebuild_security_group.id : ""
}

output "codepipeline_role" {
  value = length(aws_iam_role.codepipeline_role) > 0 ? aws_iam_role.codepipeline_role.arn : ""
}

output "sqs_url" {
  value = length(aws_sqs_queue.code_services_queue) > 0 ? aws_sqs_queue.code_services_queue.id : ""
}

output "event_mapper_role_arn" {
  value = length(aws_iam_role.event_mapper_role) > 0 ? aws_iam_role.event_mapper_role.arn : ""
}

output "event_mapper_role_policy_arn" {
  value = length(aws_iam_policy.event_mapper_role_policy) > 0 ? aws_iam_policy.event_mapper_role_policy.arn : ""
}
