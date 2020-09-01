variable "enable_rode" {
  default = true
}

variable "rode_service_account_arn" {}

variable "namespace" {}

variable "cluster" {}

variable "root_zone_name" {}

variable "localstack_enabled" {
  default = false
}