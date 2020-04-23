variable "region" {
  default = "us-east-1"
}

variable "eks_cluster_id" {}
variable "eks_openid_connect_provider_url" {}
variable "eks_openid_connect_provider_arn" {}

variable "cluster_domain" {
  default = "services.liatr.io"
}
variable "internal_cluster_domain" {
  default = "internal.services.liatr.io"
}

variable "essential_taint_key" {}

variable "enable_autoscaler_scale_down" {
  default = true
}

variable "system_namespace" {}

variable "uptime" {
  default = "Mon-Fri 05:00-19:00 America/Los_Angeles"
}
