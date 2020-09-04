module "toolchain_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = var.toolchain_namespace
  annotations = {
    name                                         = var.toolchain_namespace
    cluster                                      = var.cluster_name
    "opa.lead.liatrio/ingress-whitelist"         = "*.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}"
    "opa.lead.liatrio/image-whitelist"           = var.image_whitelist
    "opa.lead.liatrio/elb-extra-security-groups" = var.elb_security_group_id
  }
}

module "toolchain_ingress" {
  source                          = "../../../modules/lead/toolchain-ingress"
  namespace                       = var.toolchain_namespace
  cluster_domain                  = "${var.cluster_name}.${var.root_zone_name}"
  issuer_name                     = module.cluster_issuer.issuer_name
  issuer_kind                     = module.cluster_issuer.issuer_kind
  ingress_controller_type         = "LoadBalancer"
  ingress_external_traffic_policy = var.ingress_external_traffic_policy

  depends_on = [
    module.cert_manager
  ]
}
