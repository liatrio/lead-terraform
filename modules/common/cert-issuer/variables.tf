variable "namespace" {}
variable "issuer_type" {}

variable "issuer_name" {
  default = "lead-namespace-issuer"
}

variable "issuer_server" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "issuer_email" {
  default = "cloudservices@liatr.io"
}

variable "issuer_kind" {
  default = "Issuer"
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

variable "gcp_dns_project" {
  default = ""
}

#tfsec:ignore:general-secrets-sensitive-in-variable
variable "gcp_dns_service_account_secret_name" {
  default = ""
}

#tfsec:ignore:general-secrets-sensitive-in-variable
variable "gcp_dns_service_account_secret_key" {
  default = ""
}

variable "enabled" {
  default = true
}

#tfsec:ignore:general-secrets-sensitive-in-variable
variable "ca_secret" {
  default = "ca-certificate"
}
