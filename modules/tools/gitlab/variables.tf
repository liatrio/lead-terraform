variable "enable_gitlab" {
  description = "variable to decide whether to install gitlab"
  default     = false
}

variable "certmanager_issuer_email" {
  description = "email for cert manager"
  default     = "no@example.com"
}

variable "root_domain" {
  description = "domain name for GitLab"
}

variable "namespace" {
  description = "namespace to install GitLab helm chart"
  default     = "gitlab"
}
