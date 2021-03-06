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
