module "onegheorg_pipeline_iam" {
  source = "../../../../modules/environment/aws/iam/github-runner-iam"
  name                                = "liatrio-onegheorg-pipeline"
  service_account_name                = "liatrio-onegheorg-runners"
  aws_iam_openid_connect_provider_arn = "arn:aws:iam::265560927720:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/5D373074AFAEC39576C6045E44C487CC"
  aws_iam_openid_connect_provider_url = "https://oidc.eks.us-east-1.amazonaws.com/id/5D373074AFAEC39576C6045E44C487CC"
  namespace                           = var.github_runners_namespace
  roles                               = var.onegheorg_pipeline_roles
}
