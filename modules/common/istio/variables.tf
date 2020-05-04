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
  default = 5.0
}

variable "flagger_event_webhook" {}

variable "k8s_storage_class" {}

variable "jaeger_elasticsearch_host" {}
variable "jaeger_elasticsearch_username" {}
variable "jaeger_elasticsearch_password" {}

variable "ingress_class" {}
