variable "namespace" {}
variable "issuer_type" {}
variable "crd_waiter" {}

variable "issuer_name" {
  default = "lead-namespace-issuer"
}

variable "issuer_server" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "acme_solver" {
  default = "http"
}

variable "provider_http_ingress_class" {
  default = "nginx"
}

variable "provider_dns_type" {
  default = "route53"
}

variable "route53_dns_region" {
  default = ""
}

variable "route53_dns_hosted_zone" {
  default = ""
}

variable "enabled" {
  default = true
}

variable "ca_secret" {
  default = "ca-certificate"
}