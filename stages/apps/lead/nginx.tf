# create an ingress controller for handling application traffic if istio is not installed
module "app_nginx" {
  count  = var.enable_istio ? 0 : 1
  source = "../../../modules/lead/app-ingress"

  cluster_domain = "${var.cluster_name}.${var.root_zone_name}"
  issuer_name    = module.cluster_issuer.issuer_name
  issuer_kind    = module.cluster_issuer.issuer_kind
  namespace      = module.toolchain_namespace.name
}

module "monitoring_nginx" {
  count  = var.enable_istio ? 0 : 1
  source = "../../../modules/lead/app-ingress"

  cluster_domain = "${var.cluster_name}.${var.root_zone_name}"
  issuer_name    = module.cluster_issuer.issuer_name
  issuer_kind    = module.cluster_issuer.issuer_kind
  namespace      = module.monitoring_namespace.name
}