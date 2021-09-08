data "vault_generic_secret" "prometheus" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/prometheus"
}

module "monitoring_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = var.monitoring_namespace
  annotations = {
    name                                         = var.monitoring_namespace
    cluster                                      = var.cluster_name
  }
}

module "kube_prometheus_stack" {
  source = "../../../modules/tools/kube-prometheus-stack"

  namespace                    = module.monitoring_namespace.name
  grafana_hostname             = "grafana.${var.toolchain_namespace}.${var.cluster_name}.${var.root_zone_name}"
  prometheus_slack_webhook_url = data.vault_generic_secret.prometheus.data["slack-webhook-url"]
  prometheus_slack_channel     = var.prometheus_slack_channel
  ingress_class                = "toolchain-nginx"
}

module "dashboard" {
  source = "../../../modules/lead/dashboard"

  enabled           = var.enable_dashboard
  namespace         = module.monitoring_namespace.name
  dashboard_version = var.dashboard_version
}
