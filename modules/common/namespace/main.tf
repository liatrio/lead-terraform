resource "kubernetes_namespace" "ns" {
  metadata {
    name = "${var.namespace}"
    annotations = "${var.annotations}"
    labels = "${var.labels}"
  }
}

resource "kubernetes_service_account" "tiller_service_account" {
  metadata {
    name = "tiller"
    namespace = "${kubernetes_namespace.ns.metadata.0.name}"
  }
  automount_service_account_token = true
}

resource "kubernetes_role" "tiller_role" {
  metadata {
    name = "tiller-manager"
    namespace = "${kubernetes_namespace.ns.metadata.0.name}"
  }
  rule {
    api_groups = ["", "batch", "extensions", "apps","stable.liatr.io", "policy", "apiextensions.k8s.io"]
    resources = ["*"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources = ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs = ["get", "create", "watch", "delete", "list"]
  }
  rule {
    api_groups = ["certmanager.k8s.io"]
    resources = ["issuers"]
    verbs = ["get", "create", "watch", "delete", "list", "patch"]
  }
}

resource "kubernetes_role_binding" "tiller_role_binding" {
  metadata {
    name = "tiller-binding"
    namespace = "${kubernetes_namespace.ns.metadata.0.name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${kubernetes_role.tiller_role.metadata.0.name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller_service_account.metadata.0.name}"
    namespace = "${kubernetes_namespace.ns.metadata.0.name}"
  }
}
