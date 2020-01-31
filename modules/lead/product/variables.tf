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
variable "enable_istio" {
  default = true
}
variable "enable_keycloak" {
  default = true
}

variable "image_repository" {
  default = "artifactory"
  description = "Artifactory or Harbor. Used to determine product image repo manager"
}

