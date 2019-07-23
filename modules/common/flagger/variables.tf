variable "namespace" {}
variable "slack_url" {}
variable "slack_channel" {}

variable "slack_user" {
  default = "flagger"
}

variable "provider" {
  default = "istio"
}

variable "metrics_url" {
  default = "http://prometheus:9090"
}

variable "enable" {
  default = true
}
