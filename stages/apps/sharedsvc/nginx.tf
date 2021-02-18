module "nginx_ingress_namespace" {
  source      = "../../../modules/common/namespace"
  namespace   = "nginx-ingress"
  annotations = {
    name    = "nginx-ingress"
    cluster = var.eks_cluster_id
  }
}

module "wildcard" {
  source = "../../../modules/common/certificates"

  name      = "services-wildcard"
  namespace = module.nginx_ingress_namespace.name
  domain    = var.internal_cluster_domain
  enabled   = true

  issuer_name = module.internal_services_cluster_issuer.issuer_name
  issuer_kind = module.internal_services_cluster_issuer.issuer_kind
}

module "nginx" {
  source              = "../../../modules/tools/nginx"
  default_certificate = "${module.nginx_ingress_namespace.name}/${module.wildcard.cert_secret_name}"
  internal            = true
  namespace           = module.nginx_ingress_namespace.name
}
