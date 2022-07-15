resource "kubernetes_cluster_role" "cluster_role" {
  metadata {
    name = var.cluster_role_name
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      api_groups = rule.value["api_groups"]
      resources  = rule.value["resources"]
      verbs      = rule.value["verbs"]
    }
  }
}

resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
  metadata {
    name = "${var.cluster_role_name}-${var.service_account_name}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_role.metadata.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = var.service_account_name
    api_group = "rbac.authorization.k8s.io"
  }
}
