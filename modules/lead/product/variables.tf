variable "root_zone_name" {}
variable "cluster" {}
variable "issuer_type" {}
variable "ingress_controller_type" {
    default = "LoadBalancer"
}
variable "product_name" {} 
variable "image_whitelist" {}