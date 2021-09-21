variable "prometheus_slack_webhook_url" {
  default = ""
}

variable "prometheus_slack_channel" {
  default = ""
}

variable "ingress_annotations" {
  type = map(string)
}

variable "namespace" {}

variable "grafana_hostname" {}

variable "alertmanager_hostname" {}
