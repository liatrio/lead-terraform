data "vault_generic_secret" "prometheus" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/prometheus"
}

module "monitoring_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = var.monitoring_namespace
  annotations = {
    name    = var.monitoring_namespace
    cluster = var.cluster_name
  }
}

module "kube_prometheus_stack" {
  source = "../../../modules/tools/kube-prometheus-stack"

  namespace                        = module.monitoring_namespace.name
  grafana_hostname                 = "grafana.${local.external_ingress_hostname}"
  alertmanager_hostname            = "alertmanager.${local.internal_ingress_hostname}"
  prometheus_slack_webhook_url     = data.vault_generic_secret.prometheus.data["slack-webhook-url"]
  prometheus_slack_channel         = var.prometheus_slack_channel
  grafana_ingress_annotations      = local.external_ingress_annotations
  alertmanager_ingress_annotations = local.internal_ingress_annotations
}

module "dashboard" {
  source = "../../../modules/lead/dashboard"

  enabled           = var.enable_dashboard
  namespace         = module.monitoring_namespace.name
  dashboard_version = var.dashboard_version
}
