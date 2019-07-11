module "istio_namespace" {
  source    = "../namespace"
  namespace = "${var.namespace}"

  annotations {
    name = "${var.namespace}"
  }
}

resource "random_string" "kiali_admin_password" {
  length  = 10
  special = false
}

resource "kubernetes_secret" "kiali_dashboard_secret" {
  metadata {
    name      = "kiali"
    namespace = "${var.namespace}"

    labels {
      "app" = "kiali"
    }
  }

  type = "Opaque"

  data {
    "username"   = "${var.kiali_username}"
    "passphrase" = "${random_string.kiali_admin_password.result}"
  }
}

data "helm_repository" "istio" {
  name = "istio.io"
  url  = "https://storage.googleapis.com/istio-release/releases/1.2.0/charts/"
}

resource "helm_release" "istio" {
  count      = "${var.enable ? 1 : 0}"
  repository = "${data.helm_repository.istio.metadata.0.name}"
  chart      = "istio"
  namespace  = "${module.istio_namespace.name}"
  name       = "${var.namespace}"
  timeout    = 600
  wait       = true

  set {
    name  = "crd_waiter"
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

  set {
    name  = "global.k8sIngress.enabled"
    value = "true"
  }

  set {
    name  = "global.k8sIngress.enableHttps"
    value = "true"
  }

  set {
    name  = "global.k8sIngress.gatewayName"
    value = "istio-ingressgateway"
  }

  set {
    name  = "certmanager.enabled"
    value = "true"
  }

  set {
    name  = "certmanager.email"
    value = "cloudservices@liatr.io"
  }

  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "kiali.enabled"
    value = "true"
  }

  set {
    name  = "tracing.enabled"
    value = "true"
  }

  set {
    name  = "tracing.ingress.enabled"
    value = "true"
  }
}

resource "kubernetes_cluster_role" "tiller_cluster_role" {
  metadata {
    name = "${var.namespace}-tiller-manager"
  }

  rule {
    api_groups = ["", "batch", "extensions", "apps", "stable.liatr.io", "policy", "apiextensions.k8s.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs      = ["get", "create", "watch", "delete", "list", "patch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
    verbs      = ["get", "create", "watch", "delete", "list", "patch"]
  }

  rule {
    api_groups = ["certmanager.k8s.io"]
    resources  = ["issuers"]
    verbs      = ["get", "create", "watch", "delete", "list", "patch"]
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

module "istio_cert_issuer" {
  source                   = "../../common/cert-issuer"
  namespace                = "${var.namespace}"
  issuer_type              = "${var.cert_issuer_type}"
  crd_waiter               = "${var.crd_waiter}"
  provider_http_enabled    = false
  provider_dns_enabled     = true
  provider_dns_region      = "${var.region}"
  provider_dns_hosted_zone = "${var.zone_id}"
}
