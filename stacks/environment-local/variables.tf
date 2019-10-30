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
  default = "0.4.0-160-gd3913d2"
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

variable "enable_grafeas" {
  default = true
}

variable "uptime" {
  default = "always"
}

variable "builder_images_version" {
  default = "v1.0.15-7-g2465aa8"
}
variable "jenkins_image_version" {
  default = "v1.0.15-7-g2465aa8"
}
variable "image_repo" {
  default = "artifactory.toolchain.lead.prod.liatr.io/docker-registry/flywheel"
}

variable "cert_issuer_type" {
  default = "selfSigned"
}

variable "cert_issuer_server" {
  default = ""
}

locals {
  tags = {
    "Cluster" = var.cluster
  }
}

variable "grafeas_version" {
  default = "v0.1.1-4-ge024b96"
}
