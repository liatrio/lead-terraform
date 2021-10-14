resource "helm_release" "chaos_mesh" {
  repository = "https://charts.chaos-mesh.org"
  name       = "chaos-mesh"
  chart      = "chaos-mesh"
  version    = "v2.0.2"
  namespace  = var.chaos_mesh_namespace
  timeout    = 600
  wait       = true

  values = [
    templatefile("${path.module}/values.tpl", {
      chaos_mesh_hostname            = var.chaos_mesh_hostname
      chaos_mesh_ingress_annotations = var.chaos_mesh_ingress_annotations
    })
  ]
}

resource "kubernetes_service_account" "chaos_mesh_service_account" {
  metadata {
    name      = "account-cluster-manager"
    namespace = var.chaos_mesh_namespace
  }
}

resource "kubernetes_cluster_role" "chaos_mesh_role" {
  metadata {
    name = "role-cluster-manager"
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "namespaces"]
    verbs      = ["get", "watch", "list"]
  }
  rule {
    api_groups = ["chaos-mesh.org"]
    resources  = ["*"]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }
}

resource "kubernetes_cluster_role_binding" "chaos_mesh_role_binding" {
  metadata {
    name = "bind-cluster-manager"
  }
  subject {
    kind      = "ServiceAccount"
    namespace = var.chaos_mesh_namespace
    name      = "account-cluster-manager"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "role-cluster-manager"
    api_group = "rbac.authorization.k8s.io"
  }
}
