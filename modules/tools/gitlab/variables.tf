variable "certmanager_issuer_email" {
  description = "email for cert manager"
  default     = "no@example.com"
}

variable "namespace" {
  description = "namespace to install GitLab helm chart"
  default     = "gitlab"
}

variable "root_domain" {
  description = "domain name for GitLab"
}

variable "ingress_class" {
  default = "toolchain-nginx"
}

variable "cert_issuer" {
  default = "letsencrypt-dns"
}
