variable "namespace" {
}

variable "name" {
}

variable "domain" {
}

variable "enabled" {
  default = true
}

variable "issuer_name" {
  description = "Name of issuer to use to generate certificate"
  default     = "letsencrypt-dns"
}

variable "issuer_kind" {
  default = "Issuer"
}

variable "altname" {
  default = ""
}

variable "wait_for_cert" {
  default = "false"
}
