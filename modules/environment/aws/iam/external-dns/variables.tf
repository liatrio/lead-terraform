variable "namespace" {}
variable "cluster" {}
variable "openid_connect_provider_arn" {}
variable "openid_connect_provider_url" {}
variable "route53_zone_ids" {
  type = list(string)
}

variable "service_account_name" {
  default = "external-dns"
}
