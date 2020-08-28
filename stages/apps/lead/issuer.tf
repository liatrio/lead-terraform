resource "kubernetes_cluster_role" "cert_manager_cluster_role" {
  metadata {
    name = "cert-manager-cluster-role"
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps", "namespaces"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = ["*"]
    resources  = ["clusterissuers"]
    verbs      = ["*"]
  }
  provider = kubernetes
}

module "cluster_issuer" {
  source        = "../../modules/common/cert-issuer"
  namespace     = module.toolchain.namespace
  issuer_name   = "letsencrypt-dns"
  issuer_kind   = "ClusterIssuer"
  issuer_type   = var.cert_issuer_type
  issuer_server = "https://acme-v02.api.letsencrypt.org/directory"
  crd_waiter    = module.cert_manager.crd_waiter

  acme_solver       = "dns"
  provider_dns_type = "route53"

  route53_dns_region      = var.region
  route53_dns_hosted_zone = aws_route53_zone.cluster_zone.zone_id
}

module "staging_cluster_issuer" {
  source        = "../../modules/common/cert-issuer"
  namespace     = module.toolchain.namespace
  issuer_name   = "staging-letsencrypt-dns"
  issuer_kind   = "ClusterIssuer"
  issuer_type   = var.cert_issuer_type
  issuer_server = "https://acme-staging-v02.api.letsencrypt.org/directory"
  crd_waiter    = module.cert_manager.crd_waiter

  acme_solver       = "dns"
  provider_dns_type = "route53"

  route53_dns_region      = var.region
  route53_dns_hosted_zone = aws_route53_zone.cluster_zone.zone_id
}
