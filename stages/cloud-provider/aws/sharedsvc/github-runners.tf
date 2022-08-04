module "github-runners" {
  source = "../../../../modules/environment/aws/github-runners"

  cluster_name                        = var.cluster_name
  s3_logging_id                       = var.s3_logging_id
  service_accounts                    = var.github_runner_service_accounts
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
}

module "lead_environments_pipeline_iam" {
  source = "../../../../modules/environment/aws/iam/github-runner-iam"

  name                                = "liatrio-lead-environments-pipeline"
  service_account_name                = "liatrio-lead-environments-runners"
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  namespace                           = var.github_runners_namespace
  roles                               = var.lead_environments_pipeline_roles
}

module "lead_terraform_pipeline_iam" {
  source = "../../../../modules/environment/aws/iam/github-runner-iam"

  name                                = "liatrio-lead-terraform-pipeline"
  service_account_name                = "liatrio-lead-terraform-runners"
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  namespace                           = var.github_runners_namespace
  roles                               = var.lead_terraform_pipeline_roles
}
