variable "region" {}

variable "cluster_name" {}

variable "enable_google_login" {
    description = "Feature flag to enable Keycloak login using Google accounts"
}

variable "enable_test_user" {
    description = "Feature flag to enable a Keycloak tests user provided as an input"
}

variable "vault_address" {
    description = "Shared-services Vault instance url provided by app stage"
}

variable "enable_keycloak" {}

variable "enable_harbor" {}

variable "keycloak_hostname" {
    description = "Keycloak instance url provided by app stage"
}

variable "harbor_hostname" {
    description = "Harbor instance url provided by app stage"
}

variable "kibana_hostname" {
    description = "Harbor instance url provided by app stage"
}

variable "iam_caller_identity_headers" {
    description = "IAM caller identity headers provided as an input to the stage"
}

variable "toolchain_namespace" {
}
