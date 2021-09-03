variable "namespace" {}

variable "hostname" {}

variable "admin_password" {}

variable "enable_keycloak" {
  default = true
}

variable "keycloak_hostname" {}

variable "keycloak_realm" {}

variable "autoscan_images" {
  default = false
}

variable "webhooks" {
  type    = map(any)
  default = {}
}
