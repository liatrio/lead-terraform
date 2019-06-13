variable "root_zone_name" {}
variable "cluster" {}
variable "namespace" {}
variable "issuer_type" {}
variable "ingress_controller_type" {
    default = "LoadBalancer"
}