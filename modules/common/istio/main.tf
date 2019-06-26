module "istio_namespace" {
  source     = "../namespace"
  namespace  = "${var.namespace}"
  annotations {
    name = "${var.namespace}"
  }
}

data "helm_repository" "istio" {
    name = "istio.io"
    url  = "https://storage.googleapis.com/istio-release/releases/1.2.0/charts/"
}
resource "helm_release" "istio" {
  repository = "${data.helm_repository.istio.metadata.0.name}"
  chart      = "istio"
  namespace = "${module.istio_namespace.name}"
  name       = "${var.namespace}"
  timeout    = 600
  wait       = true

  set {
    name = "crd_waiter"
    value = "${var.crd_waiter}"
  }

  set {
    name  = "gateways.istio-egressgateway.enabled"
    value = "false"
  }

  set {
    name  = "gateways.istio-ingressgateway.sds.enabled"
    value = "true"
  }

}

resource "kubernetes_cluster_role" "tiller_cluster_role" {
  metadata {
    name = "${var.namespace}-tiller-manager"
  }
  rule {
    api_groups = ["", "batch", "extensions", "apps","stable.liatr.io", "policy", "apiextensions.k8s.io"]
    resources = ["*"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources = ["customresourcedefinitions"]
    verbs = ["*"]
  }
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources = ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources = ["networkpolicies"]
    verbs = ["get", "create", "watch", "delete", "list", "patch"]
  }
  rule {
    api_groups = ["certmanager.k8s.io"]
    resources = ["issuers"]
    verbs = ["get", "create", "watch", "delete", "list", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "tiller_cluster_role_binding" {
  metadata {
    name = "${var.namespace}-tiller-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${kubernetes_cluster_role.tiller_cluster_role.metadata.0.name}"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "${module.istio_namespace.name}"
  }
}
