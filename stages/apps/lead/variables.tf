variable "registry" {
  default = "ghcr.io/liatrio"
}

variable "root_zone_name" {
}

variable "cluster_name" {
}

variable "cluster_zone_id" {
  description = "Cluster zone id provided by cloud-provider stage"
}

variable "aws_environment" {}

variable "system_namespace" {
  default = "lead-system"
}

variable "toolchain_namespace" {
  default = "toolchain"
}

variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  default = ""
}

variable "image_whitelist" {
  default = ".*"
}

variable "elb_security_group_id" {
}

variable "essential_taint_key" {
}
variable "opa_failure_policy" {
  default = "Fail"
}

variable "sdm_version" {
  default = "2.0.10-3-g085d794"
}

variable "product_version" {
  default = "master"
}

variable "dashboard_version" {
  default = "0.2.0-8ed15c3a7e1"
}

variable "cert_issuer_type" {
  default = "acme"
}

variable "enable_istio" {
  default = true
}

variable "enable_keycloak" {
  default = true
}

variable "enable_operators" {
  default = true
}

variable "enable_sonarqube" {
  default = false
}

variable "enable_harbor" {
  default = true
}

variable "enable_artifactory_jcr" {
  default = false
}

variable "enable_rode" {
  default = false
}

variable "enable_dashboard" {
  default = true
}

variable "enable_autoscaler_scale_down" {
  default = true
}

variable "enable_gitlab" {
  default = false
}

variable "enable_mattermost" {
  default = false
}

variable "enable_kibana_ingress" {
  default = false
}

variable "sparky_mattermost_version" {
  default = "v0.1.0"
}

variable "mattermost_bot_email" {
  default = "sparky@liatr.io"
}
variable "mattermost_bot_username" {
  default = "sparky"
}

variable "uptime" {
  default = "Mon-Fri 05:00-19:00 America/Los_Angeles"
}

variable "downscaler_exclude_namespaces" {
  type    = list(string)
  default = ["kube-system"]
}
variable "builder_images_version" {
  default = "v1.0.15-7-g2465aa8"
}
variable "jenkins_image_version" {
  default = "v1.0.15-7-g2465aa8"
}

variable "toolchain_image_repo" {
  default = "artifactory.toolchain.lead.prod.liatr.io/docker-registry/flywheel"
}

variable "prometheus_slack_channel" {
}

locals {
  tags = {
    "Cluster" = var.cluster_name
  }
}

variable "k8s_storage_class" {
  default = "gp2"
}

variable "dashboard_elasticsearch_replicas" {
  default = 3
}

variable "lead_sdm_operators" {
  type    = list(string)
  default = ["toolchain", "elasticsearch", "slack", "product"]
}

variable "enable_aws_code_services" {
}

variable "product_types" {
  type = list(string)
}

variable "iam_caller_identity_headers" {}

variable "vault_address" {}

variable "lab_partner_version" {
}

variable "enable_lab_partner" {
  default = true
}

variable "external_dns_service_account_arn" {
}

variable "cert_manager_service_account_arn" {
}

variable "cluster_autoscaler_service_account_arn" {
}

variable "workspace_role_name" {
}

variable "codeservices_sqs_url" {
}

variable "github_runners_service_account_arn" {
}

variable "operator_slack_service_account_arn" {
}

variable "operator_jenkins_service_account_arn" {
}

variable "product_operator_service_account_arn" {
}

variable "rode_service_account_arn" {
}

variable "codeservices_event_mapper_service_account_arn" {
}

variable "codeservices_s3_bucket" {
}

variable "codeservices_codebuild_role" {
}

variable "codeservices_pipeline_role" {
}

variable "codeservices_codebuild_security_group_id" {
}

variable "vault_service_account_arn" {
}

variable "vault_dynamodb_table_name" {
}

variable "vault_kms_key_id" {
}

variable "platform_name" {
  description = "Cloud platform the config is being deployed to (aws/azure/gcs)"
  type        = string
  default     = "aws"
}

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

variable "jenkins_pipeline_source" {
  default = "git"
}

variable "velero_namespace" {
  default = "velero"
}

variable "velero_bucket_name" {
  default = ""
}

variable "velero_service_account_arn" {
  default = ""
}

variable "enable_velero" {
  default = false
}

variable "velero_enabled_namespaces" {
  type    = list(string)
  default = []
}

variable "vpn_cidr" {
  default = "10.1.32.0/20"
}

variable "sdm_image_registry"{
  default = "ghcr.io/liatrio"
}
