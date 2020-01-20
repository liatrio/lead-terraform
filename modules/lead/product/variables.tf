variable "cluster_domain" {}
variable "product_name" {}
variable "image_whitelist" {}
variable "toolchain_namespace" {
  default = "toolchain"
}
variable "builder_images_version" {
}
variable "jenkins_image_version" {
}
variable "image_repo" {
}
variable "ingress_controller_type" {}
variable "enable_istio" {
  default = true
}
variable "enable_keycloak" {
  default = true
}
