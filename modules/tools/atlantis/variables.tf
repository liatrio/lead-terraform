variable "namespace" {}
variable "github_username" {}
variable "github_token" {
  sensitive = true
}
variable "github_webhook_secret" {
  sensitive = true
}
variable "default_terraform_version" {
  default = "1.0.1"
}
variable "role_arn" {}

variable "ingress_public_hostname" {}
variable "ingress_private_hostname" {}
variable "ingress_public_class" {}
variable "ingress_private_class" {}
