terraform {
  required_version = ">= 0.13"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "1.1.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}

module "kube_prometheus_stack" {
  source = "../../../../modules/tools/kube-prometheus-stack"

  namespace                        = var.namespace
  grafana_hostname                 = var.grafana_hostname
  prometheus_slack_webhook_url     = var.prometheus_slack_webhook_url
  prometheus_slack_channel         = var.prometheus_slack_channel
  alertmanager_hostname            = "alertmanager.tests.lead-terraform.liatr.io"
  alertmanager_ingress_annotations = {}
  grafana_ingress_annotations      = {}
}
