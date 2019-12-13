resource "kubernetes_namespace" "ns" {
  count = var.enabled ? 1 : 0
  metadata {
    name        = var.namespace
    annotations = var.annotations
    labels      = var.labels
  }
}

resource "kubernetes_limit_range" "resource-limits" {
  count = var.enabled ? 1 : 0
  metadata {
    name = "namespace-resource-limits"
    namespace = kubernetes_namespace.ns[0].metadata[0].name
  }
  spec {
    limit {
      type = "Container"
      default_request = {
        cpu    = var.resource_request_cpu
        memory = var.resource_request_memory
      }
      default = {
        cpu    = var.resource_limit_cpu
        memory = var.resource_limit_memory
      }
    }
  }
}

resource "kubernetes_service_account" "tiller_service_account" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "tiller"
    namespace = kubernetes_namespace.ns[0].metadata[0].name
  }
  automount_service_account_token = true
}

resource "kubernetes_role" "tiller_role" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "tiller-manager"
    namespace = kubernetes_namespace.ns[0].metadata[0].name
  }
  rule {
    api_groups = ["", "batch", "extensions", "apps", "stable.liatr.io", "policy", "apiextensions.k8s.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs      = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
    verbs      = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["cert-manager.io"]
    resources  = ["issuers"]
    verbs      = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["networking.istio.io"]
    resources = ["*"]
    verbs = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["autoscaling"]
    resources = ["horizontalpodautoscalers"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["flagger.app"]
    resources = ["canaries","canaries/status"]
    verbs = ["*"]
  }
  rule {
    api_groups = [""]
    resources = ["secrets"]
    verbs = ["*"]
  }
}

resource "kubernetes_role_binding" "tiller_role_binding" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "tiller-binding"
    namespace = kubernetes_namespace.ns[0].metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.tiller_role[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller_service_account[0].metadata[0].name
    namespace = kubernetes_namespace.ns[0].metadata[0].name
  }
}
