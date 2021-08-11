variable "namespace" {}

variable "postgres_password" {}

variable "keycloak_admin_password" {}

variable "cluster_domain" {}

variable "ingress_class" {
  default = "toolchain-nginx"
}
