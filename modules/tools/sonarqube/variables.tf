variable "admin_password" {
  type      = string
  sensitive = true
}

variable "force_authentication" {
  default     = true
  description = "Require authentication. Set to false to enable anonymous access."
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

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "enable_keycloak" {
  type    = bool
  default = false
}

variable "keycloak_issuer_uri" {
  type    = string
  default = ""
}

variable "keycloak_client_id" {
  type    = string
  default = ""
}

variable "keycloak_client_secret" {
  type      = string
  sensitive = true
  default   = ""
}
