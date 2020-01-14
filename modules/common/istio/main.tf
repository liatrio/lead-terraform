locals {
  gcp_service_account_secret_key = "credentials.json"
}

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

data "helm_repository" "istio" {
  name = "istio.io"
  url  = "https://storage.googleapis.com/istio-release/releases/1.4.2/charts/"
}

data "template_file" "istio_values" {
  template = file("${path.module}/istio-values.tpl")

  vars = {
    domain = "${var.toolchain_namespace}.${var.cluster_domain}"
    pilotTraceSampling = var.pilot_trace_sampling
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
  version    = "1.4.2"

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
    api_groups = ["cert-manager.io"]
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

resource "kubernetes_secret" "gcp_dns_service_account_key" {
  count = var.cert_issuer_dns_provider == "gcp" ? 1 : 0

  metadata {
    name = "gcp-dns-service-account-key"
    namespace = module.istio_namespace.name
  }

  data = {
    (local.gcp_service_account_secret_key) = var.gcp_dns_service_account_json
  }
}

module "istio_cert_issuer" {
  source        = "../cert-issuer"
  enabled       = var.enabled
  namespace     = module.istio_namespace.name
  issuer_name   = var.cert_issuer_name
  issuer_type   = var.cert_issuer_type
  issuer_server = var.cert_issuer_server
  crd_waiter    = var.crd_waiter

  acme_solver             = "dns"
  provider_dns_type       = var.cert_issuer_dns_provider

  route53_dns_region      = var.route53_region
  route53_dns_hosted_zone = var.route53_zone_id

  gcp_dns_project = var.gcp_dns_project
  gcp_dns_service_account_secret_name = var.cert_issuer_dns_provider == "gcp" ? kubernetes_secret.gcp_dns_service_account_key[0].metadata[0].name : ""
  gcp_dns_service_account_secret_key = local.gcp_service_account_secret_key
}

module "istio_flagger" {
  source    = "../../common/flagger"
  enable    = var.enabled
  namespace = var.enabled ? helm_release.istio[0].metadata[0].namespace : ""
}

resource "kubernetes_horizontal_pod_autoscaler" "kiali_autoscaler" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "kiali"
    namespace = module.istio_namespace.name
  }
  spec {
    max_replicas                      = 20
    target_cpu_utilization_percentage = 80
    scale_target_ref {
      api_version = "apps/v1beta1"
      kind        = "Deployment"
      name        = "kiali"
    }
  }
}

resource "helm_release" "kiali" {
  count      = var.enabled ? 1 : 0
  chart      = "${path.module}/charts/kiali"
  namespace  = module.istio_namespace.name
  name       = "kiali"
  timeout    = 600
  wait       = true

  set {
    name  = "domain"
    value = "${var.toolchain_namespace}.${var.cluster_domain}"
  }

  set {
    name = "image"
    value = "quay.io/kiali/kiali:v1.9"
  }

  depends_on = [
    helm_release.istio
  ]
}
