variable "namespace" {
}

variable "name" {
}

variable "domain" {
}

variable "enabled" {
}

variable "acme_enabled" {
  description = "Flag to include acme section in certificate spec"
  default = true
}

variable "issuer_name" {
  description = "Name of issuer to use to generate certificate"
  default = "letsencrypt-dns"
}

variable "certificate_crd" {
}
