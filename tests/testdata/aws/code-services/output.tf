output "s3_bucket" {
  value = module.code_services.s3_bucket
}

output "codebuild_role" {
  value = module.code_services.codebuild_role
}

output "codepipeline_role" {
  value = module.code_services.codepipeline_role
}

output "sqs_url" {
  value = module.code_services.sqs_url
}

output "event_mapper_role_arn" {
  value = module.code_services.event_mapper_role_arn
}

