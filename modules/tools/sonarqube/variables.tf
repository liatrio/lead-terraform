variable "admin_password" {
  type      = string
  sensitive = true
}

variable "enable_sonarqube" {
  default = true
}

variable "force_authentication" {
  default     = true
  description = "Require authentication. Set to false to enable anoymouse access."
}

variable "ingress_annotations" {
  type    = map(string)
  default = {}
}

variable "ingress_enabled" {
  default = false
}

variable "ingress_hostname" {
  default = ""
}

variable "namespace" {}

