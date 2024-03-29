variable "vault_address" {}

variable "vault_role" {
  default = "aws-admin"
}

variable "eks_cluster_id" {}

variable "keycloak_hostname" {}

variable "harbor_hostname" {}

variable "harbor_namespace" {}

variable "sonar_keycloak_client_id" {}

variable "sonarqube_hostname" {}

variable "rode_oidc_client_id" {}

variable "rode_hostname" {}

variable "rode_ui_hostname" {}

variable "sonarqube_collector_url" {}

variable "harbor_collector_url" {}

variable "region" {
  default = "us-east-1"
}
