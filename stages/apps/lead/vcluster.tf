locals {
  vcluster_ingress_class = "vcluster"
}

module "vcluster_namespace" {
  source = "../../../modules/common/namespace"

  namespace = "vcluster"
}

// we need a dedicated instance of ingress-nginx in order to enable ssl passthrough to the k8s API server.
// we could technically enable this on an existing instance of ingress-nginx, but there's a noticable performance hit
module "nginx" {
  source = "../../../modules/tools/nginx"

  name          = "vcluster"
  namespace     = module.vcluster_namespace.name
  ingress_class = local.vcluster_ingress_class
  extra_args = {
    "enable-ssl-passthrough" : "true"
  }
}
