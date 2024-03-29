module "nginx_ingress_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = "nginx-ingress"
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

module "wildcard_external" {
  source = "../../../modules/common/certificates"

  name      = "external-services-wildcard"
  namespace = module.nginx_ingress_namespace.name
  domain    = var.cluster_domain
  enabled   = true

  issuer_name = module.external_services_cluster_issuer.issuer_name
  issuer_kind = module.external_services_cluster_issuer.issuer_kind
}

module "nginx" {
  source              = "../../../modules/tools/nginx"
  default_certificate = "${module.nginx_ingress_namespace.name}/${module.wildcard.cert_secret_name}"
  internal            = true
  namespace           = module.nginx_ingress_namespace.name
  name                = "internal"
}

module "nginx_external" {
  source              = "../../../modules/tools/nginx"
  default_certificate = "${module.nginx_ingress_namespace.name}/${module.wildcard_external.cert_secret_name}"
  internal            = false
  namespace           = module.nginx_ingress_namespace.name
  ingress_class       = "nginx-external"
  name                = "external"
}
