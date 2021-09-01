variable "namespace" {}

variable "postgres_password" {}

variable "keycloak_admin_password" {
  sensitive = true
}

variable "cluster_domain" {}

variable "ingress_class" {
  default = "toolchain-nginx"
}
