// Test variables
variable "kube_config_path" {}

variable "essential_taint_key" {
  default = ""
}

variable "tiller_service_account" {}

// SDM Module
variable "namespace" {}

variable "cluster_domain" {}

variable "issuer_name" {}

variable "issuer_kind" {}

variable "crd_waiter" {}