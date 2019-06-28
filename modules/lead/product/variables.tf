variable "cluster_domain" {}
variable "toolchain_namespace" {
  default = "toolchain"
}
variable "issuer_type" {}
variable "ingress_controller_type" {}
variable "product_name" {}
variable "image_whitelist" {}
variable "builder_images_version" {
  default = "v1.0.10"
}
