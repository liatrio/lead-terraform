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

variable "product_version" {
  default = "master"
}

variable "artifactory_license" {
}

variable "slack_bot_token" {
}

variable "slack_client_signing_secret" {
}

variable "keycloak_admin_password" {
  default = "keycloak"
}

variable "from_email" {
  default = "noreply@liatr.io"
}

variable "ingress_controller_type" {
  default = "NodePort"
}

variable "ingress_external_traffic_policy" {
  default = ""
}

variable "enable_istio" {
  default = true
}

variable "enable_artifactory" {
  default = true
}

variable "enable_gitlab" {
  default = true
}

variable "enable_keycloak" {
  default = true
}

variable "enable_mailhog" {
  default = true
}

variable "enable_operators" {
  default = true
}

variable "enable_sonarqube" {
  default = true
}

variable "enable_xray" {
  default = true
}

variable "uptime" {
  default = "Mon-Fri 07:00-19:00 America/Los_Angeles"
}

locals {
  tags = {
    "Cluster" = var.cluster
  }
}

