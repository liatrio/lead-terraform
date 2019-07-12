variable "root_zone_name" {
}

variable "cluster" {
  default = "docker-for-desktop"
}

variable "system_namespace" {
  default = "lead-system"
}

variable "toolchain_namespace" {
  default = "toolchain"
}

variable "image_whitelist" {
  default = ".*"
}

variable "opa_failure_policy" {
  default = "Fail"
}

variable "sdm_version" {
  default = "0.2.22"
}

variable "enable_xray" {
  default = "true"
}

variable "artifactory_license" {
}

variable "slack_bot_token" {
}

variable "slack_client_signing_secret" {
}

variable "enable_istio" {
  default = true
}

locals {
  tags = {
    "Cluster" = var.cluster
  }
}

