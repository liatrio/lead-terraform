data "vault_generic_secret" "prometheus" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/prometheus"
}

module "monitoring_namespace" {
  source    = "../../../modules/common/namespace"
  namespace = var.monitoring_namespace
  annotations = {
    name    = var.monitoring_namespace
    cluster = var.eks_cluster_id
  }
}

module "kube_prometheus_stack" {
  source = "../../../modules/tools/kube-prometheus-stack"

  namespace                        = module.monitoring_namespace.name
  grafana_hostname                 = "grafana.${var.internal_cluster_domain}"
  alertmanager_hostname            = "alertmanager.${var.internal_cluster_domain}"
  prometheus_slack_webhook_url     = data.vault_generic_secret.prometheus.data["slack-webhook-url"]
  prometheus_slack_channel         = var.prometheus_slack_channel
  grafana_ingress_annotations      = local.internal_ingress_annotations
  alertmanager_ingress_annotations = local.internal_ingress_annotations
}

module "dashboard" {
  source = "../../../modules/lead/dashboard"

  enabled           = true
  namespace         = module.monitoring_namespace.name
  dashboard_version = var.dashboard_version
}
