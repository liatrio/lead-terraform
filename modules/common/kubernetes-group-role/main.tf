module "namespace_creation" {
  source = "../../../modules/common/namespace"

  namespace = var.namespace
}

resource "kubernetes_role_binding" "role_binding" {
  metadata {
    name      = "${var.role_name}-binding-${module.namespace_creation.name}"
    namespace = module.namespace_creation.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.role_name
  }

  subject {
    kind      = "Group"
    name      = var.group_name
    api_group = "rbac.authorization.k8s.io"
  }
}
