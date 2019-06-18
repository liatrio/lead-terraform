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
module "system_issuer" {
  source = "../../common/cert-issuer"
  namespace  = "${module.system_namespace.name}"
  issuer_type = "${var.issuer_type}"
  crd_waiter = "${null_resource.cert_manager_crd_delay.id}"
}

resource "kubernetes_cluster_role" "tiller_cluster_role" {
  metadata {
    name = "lead-system-tiller-cluster-manager"
  }
  rule {
    api_groups = ["admissionregistration.k8s.io"]
    resources = ["validatingwebhookconfigurations","mutatingwebhookconfigurations"]
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
    verbs = ["*"]
  }
  rule {
    api_groups = ["authorization.k8s.io"]
    resources = ["selfsubjectaccessreviews","selfsubjectrulesreviews"]
    verbs = ["create"]
  }
  rule {
    api_groups = ["admission.certmanager.k8s.io"]
    resources = ["certificates","issuers","clusterissuers"]
    verbs = ["get", "create", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["certmanager.k8s.io"]
    resources = ["certificates","certificates/finalizers","issuers","clusterissuers","orders","orders/finalizers","challenges"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["authentication.k8s.io"]
    resources = ["tokenreviews"]
    verbs = ["create"]
  }
  rule {
    api_groups = ["authorization.k8s.io"]
    resources = ["subjectaccessreviews"]
    verbs = ["create"]
  }
  rule {
    api_groups = [""]
    resources = ["configmaps","events","secrets","services","pods"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["extensions"]
    resources = ["ingresses"]
    verbs = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "tiller_cluster_role_binding" {
  metadata {
    name = "lead-system-tiller-cluster-binding"
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
