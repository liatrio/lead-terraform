variable "region" {
  default = "us-east-1"
}

variable "eks_cluster_id" {}
variable "eks_openid_connect_provider_url" {}
variable "eks_openid_connect_provider_arn" {}

variable "cluster_name" {
}

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

variable "enable_dashboard" {
  default = true
}

variable "system_namespace" {}

variable "monitoring_namespace" {
  default = "monitoring"
}

variable "prometheus_slack_channel" {
}

variable "uptime" {
  default = "Mon-Fri 05:00-19:00 America/Los_Angeles"
}

variable "vault_aws_access_key_id" {}

variable "vault_aws_secret_access_key" {}

variable "vault_dynamodb_table_name" {}

variable "vault_kms_key_id" {}

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

variable "github_runners_service_account_arn" {
}

variable "iam_caller_identity_headers" {}

# example_value = {
#   rode: {
#     vault_name: "github-runner-app-sandbox"
#     namespace: "roderunners"
#   }
# }
variable "github_runner_controllers" {
  type    = map(any)
  default = {}
}

# example_value = {
#   rode: {
#     github_org: "rode"
#     namespace: "roderunners"
#     image: "node"
#     labels: ["roderunners"]
#   }
# }
variable "github_runners" {
  type    = map(any)
  default = {}
}

variable "k8s_storage_class" {
  default = "gp2"
}
