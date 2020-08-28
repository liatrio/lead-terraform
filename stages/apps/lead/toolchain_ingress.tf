module "toolchain_ingress" {
  source                  = "../../modules/lead/toolchain-ingress"
  namespace               = var.toolchain_namespace
  cluster_domain          = "${var.cluster}.${var.root_zone_name}"
  issuer_name             = module.cluster_issuer.issuer_name
  issuer_kind             = module.cluster_issuer.issuer_kind
  ingress_controller_type = "LoadBalancer"
  crd_waiter              = module.cert_manager.crd_waiter
}