variable "namespace" {}
variable "crd_waiter" {}
variable "region" {}
variable "zone_id" {}

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
