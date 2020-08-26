provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  version = "1.1.1"

  kubernetes {
    config_path = var.kube_config_path
  }
}

module "prometheus-operator" {
  source = "../../../../modules/tools/prometheus-operator"

  namespace                    = var.namespace
  grafana_hostname             = var.grafana_hostname
  prometheus_slack_webhook_url = var.prometheus_slack_webhook_url
  prometheus_slack_channel     = var.prometheus_slack_channel
}
