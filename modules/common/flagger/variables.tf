variable "namespace" {}

variable "provider" {
  default = "istio"
}

variable "metrics_url" {
  default = "http://prometheus:9090"
}

variable "enable" {
  default = true
}
