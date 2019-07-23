variable "namespace" {}
variable "crd_waiter" {}
variable "region" {}
variable "domain" {}
variable "zone_id" {}
variable "slack_url" {}
variable "slack_user" {}
variable "slack_channel" {}

variable "kiali_username" {
  default = "admin"
}

variable "cert_issuer_type" {
  default = "acme"
}

variable "cert_issuer_name" {
  default = "letsencrypt-dns"
}

variable "enable" {
  default = true
}

variable "ingress_controller_type" {
  default = "LoadBalancer"
}
