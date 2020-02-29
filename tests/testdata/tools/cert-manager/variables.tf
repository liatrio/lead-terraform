variable "kube_config_path" {}

variable "essential_taint_key" {
  default = ""
}

variable "namespace" {}

variable "tiller_service_account" {}

variable "tiller_cluster_role_binding" {}