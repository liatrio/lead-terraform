// Test variables
variable "kube_config_path" {}

variable "essential_taint_key" {
  default = ""
}

// SDM Module
variable "namespace" {}

variable "cluster_domain" {}

variable "issuer_name" {}

variable "issuer_kind" {}

variable "ingress_controller_type" {
  default = "LoadBalancer"
}

variable "service_load_balancer_source_ranges" {
  default = []
}
