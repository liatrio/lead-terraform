resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  namespace  = var.namespace
  repository = data.helm_repository.stable.name
  chart      = "prometheus-operator"
  version    = "8.3.3"
  timeout    = 600
  wait       = true

  set_sensitive {
    name = "grafana.adminPassword"
    value = random_password.password.result
  }

  values = [
    templatefile("${path.module}/values.tpl", {
      prometheus_slack_webhook_url = var.prometheus_slack_webhook_url
      prometheus_slack_channel = var.prometheus_slack_channel
      grafana_hostname = var.grafana_hostname
    })
  ]
}
