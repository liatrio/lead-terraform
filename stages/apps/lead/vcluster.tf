locals {
  vcluster_ingress_class = "vcluster"
}

module "vcluster_namespace" {
  count  = var.enable_vcluster ? 1 : 0
  source = "../../../modules/common/namespace"

  namespace = "vcluster"
}

// we need a dedicated instance of ingress-nginx in order to enable ssl passthrough to the k8s API server.
// we could technically enable this on an existing instance of ingress-nginx, but there's a noticable performance hit
module "vcluster_nginx" {
  count  = var.enable_vcluster ? 1 : 0
  source = "../../../modules/tools/nginx"

  name          = "vcluster"
  namespace     = module.vcluster_namespace[0].name
  ingress_class = local.vcluster_ingress_class
  extra_args = {
    "enable-ssl-passthrough" : "true"
  }
}
