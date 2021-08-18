variable "rode_service_account_arn" {}

variable "namespace" {}

variable "ingress_domain" {}

variable "ingress_class" {
  type    = string
  default = "toolchain-nginx"
}

variable "oidc_issuer_url" {
  description = "Leave blank to disable OIDC"
  type        = string
  default     = ""
}
variable "oidc_issuer_client_id" {
  type    = string
  default = ""
}
variable "oidc_issuer_client_secret" {
  type      = string
  sensitive = true
  default   = ""
}
