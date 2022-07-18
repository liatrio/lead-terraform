resource "kubernetes_cluster_role" "cluster_role" {
  metadata {
    name = var.role_name
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

resource "kubernetes_role_binding" "role_binding" {
  metadata {
    name      = "${var.role_name}-binding-${var.namespace}"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_role.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = var.group_name
    api_group = "rbac.authorization.k8s.io"
  }
}
