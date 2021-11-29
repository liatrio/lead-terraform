locals {
  vcluster_ingress_class      = "vcluster"
  vcluster_apps_ingress_class = "vcluster-apps"
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
  extra_args    = {
    "enable-ssl-passthrough" : "true"
  }
}

// we also need an instance of ingress-nginx that can be used to front applications running on a vcluster. ingresses and
// services are synced to the host cluster, so the host cluster needs an ingress controller that these synced ingresses
// can use.
module "vcluster_apps_wildcard_cert" {
  source = "../../../modules/common/certificates"

  name      = "vcluster-apps-wildcard"
  namespace = module.vcluster_namespace[0].name
  domain    = "vcluster-apps.${var.cluster_name}.${var.root_zone_name}"

  issuer_name = module.cluster_issuer.issuer_name
  issuer_kind = module.cluster_issuer.issuer_kind
}

module "vcluster_apps_nginx" {
  count  = var.enable_vcluster ? 1 : 0
  source = "../../../modules/tools/nginx"

  name                = "vcluster-apps"
  namespace           = module.vcluster_namespace[0].name
  ingress_class       = local.vcluster_apps_ingress_class
  default_certificate = "${module.vcluster_namespace[0].name}/${module.vcluster_apps_wildcard_cert.cert_secret_name}"
}
