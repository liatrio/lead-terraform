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

variable "vault_aws_access_key_id" {
}

variable "vault_aws_secret_access_key" {
}

variable "vault_dynamodb_table_name" {
}

variable "vault_kms_key_id" {
}

variable "cluster_autoscaler_service_account_arn" {}
variable "external_dns_service_account_arn" {}
variable "external_dns_public_service_account_arn" {}
variable "cert_manager_service_account_arn" {}

variable "docker_registry_aws_access_key_id" {}
variable "docker_registry_aws_secret_access_key" {}
variable "docker_registry_s3_bucket_name" {}

variable "dashboard_version" {
  default = "v2.0.1-11-g444016b"
}

variable "vault_address" {
  default = "https://vault.internal.services.liatr.io"
}

variable "iam_caller_identity_headers" {}
