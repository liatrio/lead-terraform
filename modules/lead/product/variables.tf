variable "cluster_domain" {}
variable "issuer_type" {}
variable "issuer_server" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
}
variable "product_name" {}
variable "image_whitelist" {}
variable "toolchain_namespace" {
  default = "toolchain"
}
variable "builder_images_version" {
  default = "v1.0.14-13-g2465aa8"
}
variable "jenkins_image_version" {
  default = "v1.0.14-13-g2465aa8"
}
variabe "image_repo" {
  default = "artifactory.toolchain.lead.prod.liatr.io/docker-registry/flywheel"
}
variable "ingress_controller_type" {}
variable "istio_enabled" {
  default = true
}
