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
    kind      = "ServiceAccount"
    name      = module.toolchain.tiller_service_account
    namespace = module.toolchain.namespace
  }
}

module "staging_cluster_issuer" {
  source      = "../../modules/common/cert-issuer"
  namespace   = module.toolchain.namespace
  issuer_name = "staging-self-signed"
  issuer_kind = "ClusterIssuer"
  issuer_type = "selfSigned"
  crd_waiter  = module.infrastructure.crd_waiter
}
