data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "external_dns" {
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "external-dns"
  version    = "2.6.3"
  namespace  = module.system_namespace.name
  name       = "external-dns"
  timeout    = 600

  values = [var.external_dns_chart_values]
  set {
    name  = "rbac.serviceAccountName"
    value = kubernetes_service_account.external_dns_service_account.metadata[0].name
  }
  set {
    name  = "policy"
    value = "sync"
  }
  set {
    name  = "logLevel"
    value = "debug"
  }

  depends_on = [kubernetes_cluster_role_binding.tiller_cluster_role_binding]
}

resource "kubernetes_service_account" "external_dns_service_account" {
  metadata {
    name      = "external-dns"
    namespace = module.system_namespace.name
    annotations = var.external_dns_service_account_annotations
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "external_dns_role" {
  metadata {
    name = "external-dns-manager"
  }
  rule {
    api_groups = [""]
    resources  = ["services", "pods", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.istio.io"]
    resources  = ["gateways"]
    verbs      = ["get", "list", "watch"]
  }
  depends_on = [kubernetes_service_account.external_dns_service_account]
}

resource "kubernetes_cluster_role_binding" "external_dns_role_binding" {
  metadata {
    name = "external-dns-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_dns_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.external_dns_service_account.metadata[0].name
    namespace = module.system_namespace.name
  }
}

