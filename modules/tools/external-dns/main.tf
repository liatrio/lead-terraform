resource "helm_release" "external_dns" {
  count      = var.enabled ? 1 : 0
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "2.21.1"
  namespace  = var.namespace
  name       = var.release_name
  timeout    = 600

  values = [
    templatefile("${path.module}/values.tpl", {
      aws_zone_type  = var.aws_zone_type
      dns_provider   = var.dns_provider
      domain_filters = yamlencode(var.domain_filters)
      istio_enabled  = var.istio_enabled
      watch_services = var.watch_services
    })
  ]

  set {
    name  = "rbac.serviceAccountName"
    value = kubernetes_service_account.external_dns_service_account[0].metadata[0].name
  }
  set {
    name  = "rbac.serviceAccountCreate"
    value = "false"
  }
  set {
    name  = "policy"
    value = "sync"
  }
  set {
    name  = "logLevel"
    value = "debug"
  }
}

resource "kubernetes_service_account" "external_dns_service_account" {
  count                           = var.enabled ? 1 : 0
  metadata {
    name        = "external-dns"
    namespace   = var.namespace
    annotations = var.service_account_annotations
  }
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "external_dns_role" {
  count = var.enabled ? 1 : 0
  metadata {
    name = "external-dns-manager"
  }
  rule {
    api_groups = [
      ""
    ]
    resources  = [
      "services",
      "pods",
      "nodes"
    ]
    verbs      = [
      "get",
      "list",
      "watch"
    ]
  }

  rule {
    api_groups = [
      "extensions",
      "networking.k8s.io"
    ]
    resources  = [
      "ingresses"
    ]
    verbs      = [
      "get",
      "list",
      "watch"
    ]
  }

  rule {
    api_groups = [
      "networking.istio.io"
    ]
    resources  = [
      "gateways"
    ]
    verbs      = [
      "get",
      "list",
      "watch"
    ]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns_role_binding" {
  count = var.enabled ? 1 : 0
  metadata {
    name = "external-dns-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_dns_role[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.external_dns_service_account[0].metadata[0].name
    namespace = var.namespace
  }
}

