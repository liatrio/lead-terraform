module "github-runners-s3" {
  source = "../../../../modules/environment/aws/github-runners-s3"

  cluster_name                        = var.cluster_name
  service_accounts                    = var.github_runner_service_accounts
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
}

module "liatrio_lead_environment_pipelines" {
  source = "../../../../modules/environment/aws/iam/github-runner-iam"

  name = "liatrio-lead-environments-pipelines"
  service_account_name = "liatrio-lead-environments-runners"
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  namespace = var.github_runners_namespace
  roles = var.lead_environments_pipeline_roles
}
