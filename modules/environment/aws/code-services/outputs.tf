output "s3_bucket" {
  value =  length(aws_s3_bucket.code_services_bucket) > 0 ? aws_s3_bucket.code_services_bucket[0].id : ""
}

output "codebuild_role" {
  value = length(aws_iam_role.codebuild_role) > 0 ? aws_iam_role.codebuild_role[0].arn : ""
}

output "codepipeline_role" {
  value = length(aws_iam_role.codepipeline_role) > 0 ? aws_iam_role.codepipeline_role[0].arn : ""
}
