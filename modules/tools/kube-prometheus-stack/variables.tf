variable "prometheus_slack_webhook_url" {
  default = ""
}

variable "prometheus_slack_channel" {
  default = ""
}


variable "namespace" {}

variable "grafana_hostname" {}

variable "alertmanager_hostname" {}

variable "alertmanager_ingress_annotations" {
  type = map(string)
}
variable "grafana_ingress_annotations" {
  type = map(string)
}
