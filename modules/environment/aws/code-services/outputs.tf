output "s3_bucket" {
  value =  aws_s3_bucket.code_services_bucket.id
}

output "codebuild_role" {
  value = aws_iam_role.codebuild_role.arn
}

output "codepipeline_role" {
  value = aws_iam_role.codepipeline_role.arn
}
