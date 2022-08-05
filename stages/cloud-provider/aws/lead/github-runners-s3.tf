module "github-runners" {
  source = "../../../../modules/environment/aws/github-runners"

  cluster_name                        = var.cluster_name
  s3_logging_id                       = var.s3_logging_id
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  service_accounts                    = var.github_runner_service_accounts
}
