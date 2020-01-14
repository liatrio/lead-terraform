resource "kubernetes_cluster_role" "cert_manager_cluster_role" {
  metadata {
    name = "cert-manager-cluster-role"
  }
  rule {
    api_groups = [""]
    resources = ["configmaps", "namespaces"]
    verbs = ["get", "list"]
  }
  rule {
    api_groups = ["*"]
    resources = ["clusterissuers"]
    verbs = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "cert_manager_cluster_role_binding" {
  metadata {
    name = "cert-manager-cluster-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cert_manager_cluster_role.metadata[0].name
  }
  subject {
    kind = "ServiceAccount"
    name = module.toolchain.tiller_service_account
    namespace = module.toolchain.namespace
  }
}

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

  providers = {
    helm: helm.toolchain
  }
}
