locals {
  enable_alertmanager = var.prometheus_slack_channel != "" && var.prometheus_slack_webhook_url != ""
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "helm_release" "kube_prometheus_stack" {
  repository = "https://prometheus-community.github.io/helm-charts"
  name       = "kube-prometheus-stack"
  namespace  = var.namespace
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
      enable_alertmanager              = local.enable_alertmanager
      prometheus_slack_webhook_url     = var.prometheus_slack_webhook_url
      prometheus_slack_channel         = var.prometheus_slack_channel
      grafana_hostname                 = var.grafana_hostname
      alertmanager_hostname            = var.alertmanager_hostname
      grafana_ingress_annotations      = var.grafana_ingress_annotations
      alertmanager_ingress_annotations = var.alertmanager_ingress_annotations
    })
  ]
}

resource "helm_release" "prometheus_resources" {
  chart     = "${path.module}/chart"
  name      = "lead-prometheus-resources"
  namespace = var.namespace
}