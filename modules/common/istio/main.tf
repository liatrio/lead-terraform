module "istio_namespace" {
  source    = "../namespace"
  enabled   = var.enabled
  namespace = var.namespace
  annotations = {
    name = var.namespace
  }
}

resource "random_string" "kiali_admin_password" {
  count   = var.enabled ? 1 : 0
  length  = 10
  special = false
}

resource "kubernetes_secret" "kiali_dashboard_secret" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "kiali"
    namespace = module.istio_namespace.name

    labels = {
      "app" = "kiali"
    }
  }

  type = "Opaque"

  data = {
    "username"   = var.kiali_username
    "passphrase" = random_string.kiali_admin_password[0].result
  }
}

module "istio_ingress" {
  source                  = "../nginx-ingress"
  enabled                 = var.enabled
  namespace               = module.istio_namespace.name
  ingress_controller_type = var.ingress_controller_type
}

data "helm_repository" "istio" {
  name = "istio.io"
  url  = "https://storage.googleapis.com/istio-release/releases/1.2.2/charts/"
}

data "template_file" "istio_values" {
  template = file("${path.module}/istio-values.tpl")

  vars = {
    domain = var.domain
  }
}

resource "helm_release" "istio" {
  count      = var.enabled ? 1 : 0
  repository = data.helm_repository.istio.metadata[0].name
  chart      = "istio"
  namespace  = module.istio_namespace.name
  name       = module.istio_namespace.name
  timeout    = 600
  wait       = true
  version    = "1.2.2"

  set {
    name  = "crd_waiter"
    value = var.crd_waiter
  }

  values = [data.template_file.istio_values.rendered]
}

resource "kubernetes_cluster_role" "tiller_cluster_role" {
  count = var.enabled ? 1 : 0

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
  count = var.enabled ? 1 : 0

  metadata {
    name = "${var.namespace}-tiller-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.tiller_cluster_role[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = module.istio_namespace.name
  }
}

module "istio_cert_issuer" {
  source                   = "../../common/cert-issuer"
  enabled                  = var.enabled
  namespace                = module.istio_namespace.name
  issuer_name              = var.cert_issuer_name
  issuer_type              = var.cert_issuer_type
  crd_waiter               = var.crd_waiter
  provider_http_enabled    = "false"
  provider_dns_enabled     = "true"
  provider_dns_region      = var.region
  provider_dns_hosted_zone = var.zone_id
}
