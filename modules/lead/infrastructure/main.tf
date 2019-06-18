module "system_namespace" {
  source     = "../../common/namespace"
  namespace  = "${var.namespace}"
  annotations {
    name = "${var.namespace}"
    cluster = "${var.cluster}"
  }
  labels {
    "openpolicyagent.org/webhook" = "ignore"
    "certmanager.k8s.io/disable-validation" = "true"
  }
}

resource "kubernetes_cluster_role" "tiller_cluster_role" {
  metadata {
    name = "lead-system-tiller-cluster-manager"
  }
  rule {
    api_groups = ["admissionregistration.k8s.io"]
    resources = ["validatingwebhookconfigurations"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources = ["customresourcedefinitions"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources = ["clusterroles", "clusterrolebindings", "roles", "rolebindings"]
    verbs = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["apiregistration.k8s.io"]
    resources = ["apiservices"]
    verbs = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["certmanager.k8s.io"]
    resources = ["certificates"]
    verbs = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps"]
    verbs = ["get", "create", "watch", "delete", "list", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "tiller_cluster_role_binding" {
  metadata {
    name = "tiller-cluster-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${kubernetes_cluster_role.tiller_cluster_role.metadata.0.name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${module.system_namespace.tiller_service_account}"
    namespace = "${module.system_namespace.name}"
  }
}

module "opa" {
  enable_opa = "${var.enable_opa}"
  source    = "../../common/opa"
  namespace = "${module.system_namespace.name}"
  opa_failure_policy = "${var.opa_failure_policy}"
}
