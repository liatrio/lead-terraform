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
// we can also reuse this nginx instance to front applications that are running on each vcluster. ingresses and
// services are synced to the host cluster, so the host cluster needs an ingress controller that these synced ingresses
// can use.
module "vcluster_apps_wildcard_cert" {
  source = "../../../modules/common/certificates"

  name      = "vcluster-apps-wildcard"
  namespace = module.vcluster_namespace[0].name
  domain    = "vcluster-apps.vcluster.${var.cluster_name}.${var.root_zone_name}"

  issuer_name = module.cluster_issuer.issuer_name
  issuer_kind = module.cluster_issuer.issuer_kind
}

module "vcluster_nginx" {
  count  = var.enable_vcluster ? 1 : 0
  source = "../../../modules/tools/nginx"

  name                = "vcluster"
  namespace           = module.vcluster_namespace[0].name
  ingress_class       = local.vcluster_ingress_class
  default_certificate = "${module.vcluster_namespace[0].name}/${module.vcluster_apps_wildcard_cert.cert_secret_name}"
  extra_args = {
    "enable-ssl-passthrough" : "true"
  }
}
