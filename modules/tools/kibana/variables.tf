variable "namespace" {}
variable "elasticsearch_credentials_secret_name" {}
variable "elasticsearch_certificates_secret_name" {}

// variables for keycloak config (gatekeeper)
variable "enable_keycloak" {}
variable "keycloak_hostname" {}
variable "keycloak_admin_credential_secret" {}
variable "keycloak_realm" {}
variable "toolchain_namespace" {}
variable "kibana_hostname" {}
