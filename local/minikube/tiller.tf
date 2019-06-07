provider "kubernetes" {
  config_context_cluster   = "mycluster"
}

variable "system_namespace" {
  description = "Namespace for cluster administration tools"
  default = "lead-system"
}

# Make a namespace for cluster-wide system components
resource "kubernetes_namespace" "lead_system" {
  metadata {
    annotations {
      name = "${var.system_namespace}"
      api_group = "rbac.authorization.k8s.io"
    }

    name = "${var.system_namespace}"
  }
}

# Make a service account for tiller
resource "kubernetes_service_account" "tiller_service_account" {
  metadata {
    name = "tiller"
    namespace = "${kubernetes_namespace.lead_system.metadata.0.name}"
  }
  automount_service_account_token = true
}

# Make a role for tiller to use
resource "kubernetes_role" "tiller_role" {
  metadata {
    name = "tiller-manager"
    namespace = "${kubernetes_namespace.lead_system.metadata.0.name}"
  }
  rule {
    api_groups = ["", "batch", "extensions", "apps"]
    resources = ["*"]
    verbs = ["*"]
  }
}

# Make a cluster role that lets tiller manage CRDs
resource "kubernetes_cluster_role" "crd_manager" {
  metadata {
    name = "crd-manager"
  }
  rule {
    api_groups = ["*"]
    resources = ["customresourcedefinitions"]
    verbs = ["*"]
  }
}

# Give tiller access to manage CRDs
resource "kubernetes_cluster_role_binding" "tiller_crd_manager_binding" {
  "metadata" {
    name = "tiller-crd-manager-binding"
  }
  "role_ref" {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
//    name = "${kubernetes_cluster_role.crd_manager.metadata.0.name}"
  }
  "subject" {
    kind = "ServiceAccount"
    name = "${kubernetes_service_account.tiller_service_account.metadata.0.name}"
    namespace = "${kubernetes_namespace.lead_system.metadata.0.name}"
  }
}

# Give tiller access to manage its namespace
resource "kubernetes_role_binding" "tiller_role_binding" {
  metadata {
    name = "tiller-binding"
    namespace = "${kubernetes_namespace.lead_system.metadata.0.name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${kubernetes_role.tiller_role.metadata.0.name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.tiller_service_account.metadata.0.name}"
    namespace = "${kubernetes_namespace.lead_system.metadata.0.name}"
  }
}
