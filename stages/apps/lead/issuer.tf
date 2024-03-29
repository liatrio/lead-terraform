locals {
  lets_encrypt_production_server = "https://acme-v02.api.letsencrypt.org/directory"
  lets_encrypt_staging_server    = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

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
  source        = "../../../modules/common/cert-issuer"
  namespace     = module.toolchain_namespace.name
  issuer_name   = "letsencrypt-dns"
  issuer_kind   = "ClusterIssuer"
  issuer_type   = var.cert_issuer_type
  issuer_server = local.lets_encrypt_production_server

  acme_solver       = "dns"
  provider_dns_type = "route53"

  route53_dns_region      = var.region
  route53_dns_hosted_zone = var.cluster_zone_id

  depends_on = [
    module.cert_manager
  ]
}

module "staging_cluster_issuer" {
  source        = "../../../modules/common/cert-issuer"
  namespace     = module.toolchain_namespace.name
  issuer_name   = "staging-letsencrypt-dns"
  issuer_kind   = "ClusterIssuer"
  issuer_type   = var.cert_issuer_type
  issuer_server = local.lets_encrypt_staging_server

  acme_solver       = "dns"
  provider_dns_type = "route53"

  route53_dns_region      = var.region
  route53_dns_hosted_zone = var.cluster_zone_id

  depends_on = [
    module.cert_manager
  ]
}
