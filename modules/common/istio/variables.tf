variable "namespace" {}
variable "crd_waiter" {}
variable "toolchain_namespace" {}
variable "cluster_domain" {}

variable "kiali_username" {
  default = "admin"
}

variable "issuer_name" {}

variable "issuer_kind" {}

variable "enabled" {
  default = true
}

variable "ingress_controller_type" {
  default = "LoadBalancer"
}

variable "pilot_trace_sampling" {
  default = 10.0
}
