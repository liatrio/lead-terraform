variable "kube_config_path" {}
variable "namespace" {}
variable "domain_filters" {
  default = [
    "test.com"
  ]
}
variable "istio_enabled" {}
