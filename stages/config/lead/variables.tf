variable "region" {}

variable "cluster_name" {}

variable "enable_google_login" {
  description = "Feature flag to enable Keycloak login using Google accounts"
}

variable "enable_test_user" {
  description = "Feature flag to enable a Keycloak tests user provided as an input"
}

variable "vault_address" {
  description = "Shared-services Vault instance url"
}

variable "enable_keycloak" {}

variable "enable_harbor" {}

variable "enable_artifactory_jcr" {
  default = false
}

variable "enable_sonarqube" {
  default = false
}

variable "keycloak_hostname" {
  description = "Keycloak hostname provided by app stage"
}

variable "harbor_hostname" {
  description = "Harbor hostname provided by app stage"
}

variable "artifactory_jcr_hostname" {
  description = "Artifactory hostname provided by app stage"
  default = ""
}

variable "kibana_hostname" {
  description = "Kibana hostname provided by app stage"
}

variable "lead_vault_hostname" {
  description = "LEAD Vault hostname provided by app stage"
}

variable "lead_vault_token_reviewer_kubernetes_secret_name" {
  description = "The name of the Kubernetes Secret that contains the service account token Vault will use to verify other Kubernetes service account tokens"
}

variable "lead_vault_root_token_kubernetes_secret_name" {
  description = "The name of the Kubernetes Secret that contains the root token for Vault"
}

variable "iam_caller_identity_headers" {
  description = "IAM caller identity headers provided as an input to the stage"
}

variable "toolchain_namespace" {
}
