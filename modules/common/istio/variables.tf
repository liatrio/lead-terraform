variable "namespace" {}
variable "crd_waiter" {}
variable "domain" {}

variable "kiali_username" {
  default = "admin"
}

variable "cert_issuer_type" {
  default = "acme"
}

variable "cert_issuer_server" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "cert_issuer_name" {
  default = "letsencrypt-dns"
}

variable "cert_issuer_dns_provider" {
  default = "route53"
}

variable "route53_zone_id" {
  default = ""
}

variable "route53_region" {
  default = ""
}

variable "gcp_dns_project" {
  default = ""
}

variable "gcp_dns_service_account_json" {
  default = ""
}

variable "enabled" {
  default = true
}

variable "ingress_controller_type" {
  default = "LoadBalancer"
}

variable "pilot_trace_sampling" {
  default = 10.0
}
