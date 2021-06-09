variable "namespace" {}
variable "name" {}
variable "ingress_controller_type" {}
variable "ingress_class" {
  default = "nginx"
}
variable "ingress_external_traffic_policy" {
  default = ""
}
variable "enabled" {
  default = true
}
variable "service_account" {}
variable "cluster_wide" {
  default = false
}
variable "default_certificate" {
  default = ""
}
variable "service_annotations" {
  type    = map(string)
  default = {}
}

variable "service_load_balancer_source_ranges" {
  type    = list(string)
  default = []
}

variable "deployment_annotations" {
  default = []
}
