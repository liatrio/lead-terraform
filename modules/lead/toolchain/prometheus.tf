data "template_file" "prometheus_values" {
  template = file("${path.module}/prometheus-values.tpl")

  vars = {
    prometheus_slack_webhook_url = var.prometheus_slack_webhook_url
    prometheus_slack_channel = var.prometheus_slack_channel
    grafana_hostname = "grafana.${module.toolchain_namespace.name}.${var.cluster}.${var.root_zone_name}"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "helm_release" "prometheus_operator" {
  name       = "prometheus-operator"
  namespace  = module.toolchain_namespace.name
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "prometheus-operator"
  version    = "8.3.3"
  timeout    = 600
  wait       = true
  provider   = helm.toolchain

  set_sensitive {
    name = "grafana.adminPassword"
    value = random_password.password.result
  }

  values = [data.template_file.prometheus_values.rendered]
}
