module "github-runners" {
  source = "../../../../modules/environment/aws/github-runners"

  cluster_name                        = var.cluster_name
  s3_logging_id                       = module.s3-logging.s3_logging_bucket_id
  service_accounts                    = var.github_runner_service_accounts
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
}

module "lead_environments_pipeline_iam" {
  source = "../../../../modules/environment/aws/iam/github-runner-iam"

  name                                = "shared-svc-b-liatrio-lead-environments-pipeline"
  service_account_name                = "shared-svc-b-liatrio-lead-environments-runners"
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  namespace                           = var.github_runners_namespace
  roles                               = var.lead_environments_pipeline_roles
}

module "lead_terraform_pipeline_iam" {
  source = "../../../../modules/environment/aws/iam/github-runner-iam"

  name                                = "${var.cluster_name}-liatrio-lead-terraform-pipeline"
  service_account_name                = "${var.cluster_name}-liatrio-lead-terraform-runners"
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  namespace                           = var.github_runners_namespace
  roles                               = var.lead_terraform_pipeline_roles
}

module "lead_terraform_github_runner_iam" {
  source = "../../../../modules/environment/aws/iam/github-runner-iam"

  name                                = "${var.cluster_name}-liatrio-aws-terraform-runners"
  service_account_name                = "${var.cluster_name}-liatrio-aws-terraform-runners"
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  namespace                           = var.github_runners_namespace
  roles = [
    "arn:aws:iam::489130170427:role/Developer", // prod
    "arn:aws:iam::281127131043:role/Developer", // non-prod
    "arn:aws:iam::774051255656:role/Developer", // sandbox
  ]
}
