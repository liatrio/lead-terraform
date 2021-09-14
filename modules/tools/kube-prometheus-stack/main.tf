locals {
  enable_alertmanager = var.prometheus_slack_channel != "" && var.prometheus_slack_webhook_url != ""
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "18.0.3"
  timeout    = 600
  wait       = true

  set_sensitive {
    name  = "grafana.adminPassword"
    value = random_password.password.result
  }

  values = [
    templatefile("${path.module}/values.tpl", {
      enable_alertmanager          = local.enable_alertmanager
      prometheus_slack_webhook_url = var.prometheus_slack_webhook_url
      prometheus_slack_channel     = var.prometheus_slack_channel
      grafana_hostname             = var.grafana_hostname
      ingress_annotations          = var.ingress_annotations
    })
  ]
}

resource "kubernetes_manifest" "kube_prometheus_harbor_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "kube-prometheus-stack-harbor"
      namespace = var.namespace
      labels = {
        app     = "kube-prometheus-stack-harbor"
        release = "kube-prometheus-stack"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app     = "harbor"
          release = "harbor"
        }
      }
      endpoints = [{
        port = "metrics"
      }]
      namespaceSelector = {
        any = "false"
        matchNames = [
          "toolchain",
          "harbor"
        ]
      }
    }
  }
}
