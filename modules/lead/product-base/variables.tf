variable "cluster_domain" {}
variable "product_name" {}
variable "image_whitelist" {}
variable "vault_namespace" {}
variable "vault_root_token_secret" {}
variable "vault_external" {
  default = false
}
