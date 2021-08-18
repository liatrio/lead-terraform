variable "rode_service_account_arn" {}

variable "namespace" {}

variable "ingress_domain" {}

variable "ingress_class" {
  type    = string
  default = "toolchain-nginx"
}
