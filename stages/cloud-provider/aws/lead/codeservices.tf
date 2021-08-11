module "codeservices" {
  source = "../../../../modules/environment/aws/code-services"

  enable_aws_code_services    = var.enable_aws_code_services
  cluster                     = var.cluster_name
  region                      = var.region
  account_id                  = data.aws_caller_identity.current.account_id
  toolchain_namespace         = var.toolchain_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider.arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider.url
  vpc_name                    = var.vpc_name
}
