variable "namespace" {}

variable "rode_ingress_hostname" {}

variable "rode_grpc_ingress_hostname" {}

variable "rode_ui_enabled" {
  default = false
}

variable "ui_ingress_hostname" {
  description = "Leave blank to disable rode-ui"
  default     = ""
}

variable "ingress_class" {
  default = "toolchain-nginx"
}

variable "oidc_issuer_url" {
  description = "Leave blank to disable OIDC"
  default     = ""
}
variable "oidc_client_id" {
  default = ""
}
variable "oidc_client_secret" {
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

variable "tfsec_collector_hostname" {
  type    = string
  default = ""
}

variable "build_collector_hostname" {
  type    = string
  default = ""
}
