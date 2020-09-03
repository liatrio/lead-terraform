variable "namespace" {}
variable "enabled" {}
variable "extra_values" {
  default = ""
}
variable "cluster" {}
variable "region" {
  default = "us-east-1"
}
variable "enable_autoscaler_scale_down" {}
variable "cluster_autoscaler_service_account_arn" {}
