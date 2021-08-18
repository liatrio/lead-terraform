module "rode_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = "rode"
}

module "rode" {
  source = "../../../modules/tools/rode"

  namespace                = module.rode_namespace.name
  rode_service_account_arn = var.rode_service_account_arn
  ingress_domain           = var.cluster_domain
  ingress_class            = module.nginx_external.ingress_class
}
