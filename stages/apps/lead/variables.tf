variable "root_zone_name" {
}

variable "cluster_name" {
}

variable "cluster_zone_id" {
  description = "Cluster zone id provided by cloud-provider stage"
  default = ""
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
  default = ""
}

variable "essential_taint_key" {
  default = ""
}
variable "opa_failure_policy" {
  default = "Fail"
}

variable "sdm_version" {
  default = "0.4.0-38-gc65319f"
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
  default = true
}

variable "enable_harbor" {
  default = true
}

variable "enable_rode" {
  default = true
}

variable "enable_dashboard" {
  default = true
}

variable "enable_cluster_autoscaler" {
  default = true
}

variable "enable_kube_downscaler" {
  default = true
}

variable "enable_k8s_spot_termination_handler" {
  default = true
}

variable "enable_cluster_issuer" {
  default = true
}

variable "enable_external_dns" {
  default = true
}

variable "enable_autoscaler_scale_down" {
  default = true
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
  default = ""
}

variable "cert_manager_service_account_arn" {
  default = ""
}

variable "cluster_autoscaler_service_account_arn" {
  default = ""
}

variable "workspace_role_name" {
  default = ""
}

variable "codeservices_sqs_url" {
  default = ""
}

variable "operator_slack_service_account_arn" {
  default = ""
}

variable "operator_jenkins_service_account_arn" {
  default = ""
}

variable "product_operator_service_account_arn" {
  default = ""
}

variable "rode_service_account_arn" {
  default = ""
}

variable "codeservices_event_mapper_service_account_arn" {
  default = ""
}

variable "codeservices_s3_bucket" {
  default = ""
}

variable "codeservices_codebuild_role" {
  default = ""
}

variable "codeservices_pipeline_role" {
  default = ""
}

variable "codeservices_codebuild_security_group_id" {
  default = ""
}

variable "vault_aws_access_key_id" {
  default = ""
}

variable "vault_aws_secret_access_key" {
  default = ""
}

variable "vault_dynamodb_table_name" {
  default = ""
}

variable "vault_kms_key_id" {
  default = ""
}
