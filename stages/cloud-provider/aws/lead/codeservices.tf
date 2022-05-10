module "codeservices" {
  count  = var.enable_aws_code_services ? 1 : 0
  source = "../../../../modules/environment/aws/code-services"

  cluster                     = var.cluster_name
  region                      = var.region
  account_id                  = data.aws_caller_identity.current.account_id
  toolchain_namespace         = var.toolchain_namespace
  openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn
  openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  vpc_name                    = var.vpc_name
}
