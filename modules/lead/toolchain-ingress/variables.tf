variable "namespace" {}

variable "cluster_domain" {}

variable "issuer_kind" {}

variable "issuer_name" {}

variable "crd_waiter" {}

variable "ingress_controller_type" {
  default = "LoadBalancer"
}

variable "ingress_external_traffic_policy" {
  default = ""
}
