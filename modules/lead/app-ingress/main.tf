module "staging_app_wildcard" {
  source = "../../common/certificates"

  name      = "staging-app-wildcard"
  namespace = var.namespace
  domain    = "staging.apps.${var.cluster_domain}"

  issuer_name = var.issuer_name
  issuer_kind = var.issuer_kind
}

module "prod_app_wildcard" {
  source = "../../common/certificates"

  name      = "prod-app-wildcard"
  namespace = var.namespace
  domain    = "prod.apps.${var.cluster_domain}"

  issuer_name = var.issuer_name
  issuer_kind = var.issuer_kind
}

module "staging_app_nginx" {
  source = "../../tools/nginx"

  name                = "staging-app"
  ingress_class       = "staging-app-nginx"
  namespace           = var.namespace
  default_certificate = "${var.namespace}/${module.staging_app_wildcard.cert_secret_name}"
}

module "prod_app_nginx" {
  source = "../../tools/nginx"

  name                = "production-app"
  ingress_class       = "production-app-nginx"
  namespace           = var.namespace
  default_certificate = "${var.namespace}/${module.prod_app_wildcard.cert_secret_name}"
}
