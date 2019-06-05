variable "root_zone_name" {}

variable "cluster" {
  default = "minikube"
}

variable "system_namespace" {
  default = "lead-system"
}

variable "toolchain_namespace" {
  default = "toolchain"
}

variable "key_name" {
  default = ""
}

variable "image_whitelist" {
  default = ".*"
}

variable "opa_failure_policy" {
  default = "Fail"
}

variable "sdm_version" {
  default = "0.2.7"
}

variable "dashboard_version" {
  default = "0.2.0-b55d1623b11"
}

#variable "bitbucket_token" {}
#variable "jira_token" {}
#variable "slack_webhook_url" {}
#variable "slack_access_token" {}
#variable "slack_clientid" {}
#variable "slack_clientsecret" {}
#variable "slack_verification_token" {}

locals {
  tags = {
    "Cluster" = "${var.cluster}"
  }
}
