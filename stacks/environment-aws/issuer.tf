module "cluster_issuer" {
  source        = "../../modules/common/cert-issuer"
  namespace     = module.toolchain.namespace
  issuer_name   = "letsencrypt-dns"
  issuer_kind   = "ClusterIssuer"
  issuer_type   = var.cert_issuer_type
  issuer_server = var.cert_issuer_server
  crd_waiter    = module.infrastructure.crd_waiter

  acme_solver             = "dns"
  provider_dns_type       = "route53"

  route53_dns_region      = var.region
  route53_dns_hosted_zone = aws_route53_zone.cluster_zone.zone_id
}
