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
  type    = map(string)
  default = {}
}

variable "operator_slack_service_account_annotations" {
  type    = map(string)
  default = {}
}

variable "operator_jenkins_service_account_annotations" {
  type    = map(string)
  default = {}
}

variable "operator_product_service_account_annotations" {
  type    = map(string)
  default = {}
}

variable "operators" {
  type    = list(string)
  default = ["toolchain", "elasticsearch", "slack", "product"]
}

variable "enable_aws_event_mapper" {
}

variable "remote_state_config" {
  default = ""
}

variable "sqs_url" {
  default = ""
}
