variable "root_zone_name" {
}

variable "cluster" {
}

variable "namespace" {
}

variable "system_namespace" {
}

variable "sdm_version" {
}

variable "product_version" {
}

variable "slack_bot_token" {
}

variable "slack_client_signing_secret" {
}

variable "workspace_role_name" {
  default = "default"
}

variable "enable_operators" {
  default = true
}

variable "region" {
  default = "us-east-1"
}

variable "product_stack" {
  default = "product-local"
}

variable "product_vars" {
  type    = map
  default = {}
}

variable "operator_slack_service_account_annotations" {
  type    = map
  default = {}
}

variable "operator_jenkins_service_account_annotations" {
  type    = map
  default = {}
}

variable "enable_aws_event_mapper" {
}

variable "code_services_s3_bucket" {
  default = ""
}

variable "codebuild_role" {
  default = ""
}

variable "codepipeline_role" {
  default = ""
}

variable "codebuild_user" {
  default = ""
}
