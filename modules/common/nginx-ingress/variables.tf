variable "namespace" {}
variable "ingress_controller_type" {}
variable "ingress_external_traffic_policy" {
  default = ""
}
variable "enabled" {
  default = true
}
