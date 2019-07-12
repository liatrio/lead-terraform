variable "cluster_domain" {}
variable "issuer_type" {}
variable "product_name" {}
variable "image_whitelist" {}
variable "toolchain_namespace" {
  default = "toolchain"
}
variable "builder_images_version" {
  default = "v1.0.10"
}
variable "ingress_controller_type" {}
variable "istio_enabled" {
  default = true
}
