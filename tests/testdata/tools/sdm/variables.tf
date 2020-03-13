// Test variables
variable "kube_config_path" {}

variable "essential_taint_key" {
  default = ""
}

// SDM Module

variable "product_stack" {}

variable "namespace" {}

variable "system_namespace" {}

variable "sdm_version" {}

variable "cluster_id" {}

variable "product_version" {}

variable "slack_bot_token" {}

variable "slack_client_signing_secret" {}

variable "root_zone_name" {}
