data "aws_route53_zone" "public_internal_services_liatr_io" {
  name         = "${var.internal_cluster_domain}."
}

module "internal_services_cluster_issuer" {
  source        = "../../../modules/common/cert-issuer"
  namespace     = module.system_namespace.name
  issuer_name   = "letsencrypt-dns"
  issuer_kind   = "ClusterIssuer"
  issuer_type   = "acme"
  issuer_server = "https://acme-v02.api.letsencrypt.org/directory"

  acme_solver       = "dns"
  provider_dns_type = "route53"

  route53_dns_region      = var.region
  route53_dns_hosted_zone = data.aws_route53_zone.public_internal_services_liatr_io.zone_id

  depends_on = [
    module.cert_manager
  ]
}

module "internal_services_staging_cluster_issuer" {
  source        = "../../../modules/common/cert-issuer"
  namespace     = module.system_namespace.name
  issuer_name   = "staging-letsencrypt-dns"
  issuer_kind   = "ClusterIssuer"
  issuer_type   = "acme"
  issuer_server = "https://acme-staging-v02.api.letsencrypt.org/directory"

  acme_solver       = "dns"
  provider_dns_type = "route53"

  route53_dns_region      = var.region
  route53_dns_hosted_zone = data.aws_route53_zone.public_internal_services_liatr_io.zone_id

  depends_on = [
    module.cert_manager
  ]
}
