variable "namespace" {}
variable "issuer_type" {}
variable "crd_waiter" {}

variable "issuer_name" {
  default = "lead-namespace-issuer"
}

variable "provider_http_enabled" {
  default = "true"
}

variable "provider_http_ingress_class" {
  default = "nginx"
}

variable "provider_dns_enabled" {
  default = "false"
}

variable "provider_dns_name" {
  default = "liatrio-route53"
}

variable "provider_dns_type" {
  default = "route53"
}

variable "provider_dns_region" {
  default = ""
}

variable "provider_dns_hosted_zone" {
  default = ""
}

variable "enabled" {
  default = true
}

