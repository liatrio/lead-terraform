data "vault_generic_secret" "prometheus" {
  path = "lead/aws/${data.aws_caller_identity.current.account_id}/prometheus"
}

module "prometheus-operator" {
  source = "../../modules/tools/prometheus-operator"

  namespace                    = var.toolchain_namespace
  grafana_hostname             = "grafana.${var.toolchain_namespace}.${var.cluster}.${var.root_zone_name}"
  prometheus_slack_webhook_url = data.vault_generic_secret.prometheus.data["slack-webhook-url"]
  prometheus_slack_channel     = var.prometheus_slack_channel
}
