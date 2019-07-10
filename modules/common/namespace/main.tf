resource "kubernetes_namespace" "ns" {
  metadata {
    name        = var.namespace
    annotations = var.annotations
    labels      = var.labels
  }
}

resource "kubernetes_service_account" "tiller_service_account" {
  metadata {
    name      = "tiller"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  automount_service_account_token = true
}

resource "kubernetes_role" "tiller_role" {
  metadata {
    name      = "tiller-manager"
    namespace = kubernetes_namespace.ns.metadata[0].name
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
    api_groups = ["certmanager.k8s.io"]
    resources  = ["issuers"]
    verbs      = ["get", "create", "watch", "delete", "list", "patch"]
  }
  # rule {
  #   api_groups = ["autoscaling"]
  #   resources = ["horizontalpodautoscalers"]
  #   verbs = ["*"]
  # }
  # rule {
  #   api_groups = ["appmesh.k8s.aws"]
  #   resources = ["meshes","meshes/status","virtualnodes","virtualnodes/status","virtualservices","virtualservices/status"]
  #   verbs = ["*"]
  # }
  # rule {
  #   api_groups = ["flagger.app"]
  #   resources = ["canaries","canaries/status"]
  #   verbs = ["*"]
  # }
  # rule {
  #   api_groups = ["gateway.solo.io"]
  #   resources = ["gateways","virtualservices"]
  #   verbs = ["*"]
  # }
  # rule {
  #   api_groups = ["gloo.solo.io"]
  #   resources = ["proxies","settings","upstreamgroups","upstreams","virtualservices"]
  #   verbs = ["*"]
  # }
  # rule {
  #   api_groups = ["split.smi-spec.io"]
  #   resources = ["trafficsplits"]
  #   verbs = ["*"]
  # }
}

resource "kubernetes_role_binding" "tiller_role_binding" {
  metadata {
    name      = "tiller-binding"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.tiller_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller_service_account.metadata[0].name
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
}

