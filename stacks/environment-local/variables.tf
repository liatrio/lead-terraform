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
}

variable "dashboard_version" {
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

variable "enable_dashboard" {
  default = false
}

variable "enable_harbor" {
  default = true
}

variable "uptime" {
  default = "always"
}

variable "builder_images_version" {
}
variable "jenkins_image_version" {
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

variable "prometheus_slack_channel" {
}

variable "prometheus_slack_webhook_url" {
}

variable "k8s_storage_class" {
  default = "hostpath"
}

variable "lead_sdm_operators" {
  type    = list
  default = ["toolchain", "elasticsearch", "slack", "product"]
}

variable "toolchain_image_repo" {
}

variable "enable_aws_code_services" {
}

variable "enable_lab_partner" {
}

variable "lab_partner_version" {
}

variable "team_id" {
}
