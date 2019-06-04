module "system_namespace" {
  source     = "../../common/namespace"
  namespace  = "${var.namespace}"
  annotations {
    name = "${var.namespace}"
    cluster = "${var.cluster}"
  }
  labels {
    "openpolicyagent.org/webhook" = "ignore"
  }
}

module "opa" {
  enable_opa = "${var.enable_opa}"
  source    = "../../common/opa"
  namespace = "${var.namespace}"
  opa_failure_policy = "${var.opa_failure_policy}"
}




resource "kubernetes_cluster_role" "tiller_cluster_role" {
  metadata {
    name = "tiller-cluster-manager"
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
