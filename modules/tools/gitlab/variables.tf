variable "certmanager_issuer_email" {
  description = "email for cert manager"
  default     = "no@example.com"
}

variable "gitlab_domain_name" {
  description = "domain name for GitLab"
}

variable "namespace" {
  description = "namespace to install GitLab helm chart"
  default     = "gitlab"
}
