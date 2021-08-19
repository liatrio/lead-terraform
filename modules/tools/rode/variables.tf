variable "rode_service_account_arn" {} #todo: is this needed?

variable "namespace" {}

variable "rode_ingress_hostname" {}

variable "ui_ingress_hostname" {
  description = "Leave blank to disable rode-ui"
  default = ""
}

variable "ingress_class" {
  default = "toolchain-nginx"
}

variable "oidc_issuer_url" {
  description = "Leave blank to disable OIDC"
  default     = ""
}
variable "oidc_issuer_client_id" {
  default = ""
}
variable "oidc_issuer_client_secret" {
  sensitive = true
  default   = ""
}

variable "grafeas_elasticsearch_username" {
  sensitive = true
}

variable "grafeas_elasticsearch_password" {
  sensitive = true
}

variable "grafeas_image_tag" {
  default = "v0.8.8"
}
