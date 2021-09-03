locals {
  enable_alertmanager = var.prometheus_slack_channel != "" && var.prometheus_slack_webhook_url != ""
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
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
      ingress_class                = var.ingress_class
    })
  ]
}
