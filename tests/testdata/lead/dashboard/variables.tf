// Test variables
variable "kube_config_path" {}

variable "essential_taint_key" {
  default = ""
}

// Dashboard variables

variable "namespace" {}

variable "root_zone_name" {}

variable "cluster_id" {}

variable "cluster_domain" {}

variable "dashboard_version" {}

variable "k8s_storage_class" {}

variable "crd_waiter" {
  default = ""
}

variable "local" {
  default = false
}