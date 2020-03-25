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
}

module "staging_cluster_issuer" {
  source      = "../../modules/common/cert-issuer"
  namespace   = module.toolchain.namespace
  issuer_name = "staging-self-signed"
  issuer_kind = "ClusterIssuer"
  issuer_type = "selfSigned"
  crd_waiter  = module.infrastructure.crd_waiter

  providers = {
    kubernetes = kubernetes
    helm       = helm.toolchain
  }
}
