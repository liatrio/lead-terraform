data "kubernetes_secret" "vault_root_token" {
  metadata {
    name      = var.lead_vault_root_token_kubernetes_secret_name
    namespace = var.toolchain_namespace
  }
}

data "kubernetes_secret" "vault_token_reviewer_service_account_token" {
  metadata {
    name      = var.lead_vault_token_reviewer_kubernetes_secret_name
    namespace = var.toolchain_namespace
  }
}

provider "vault" {
  alias   = "lead"
  token   = data.kubernetes_secret.vault_root_token.data["token"]
  address = "https://${var.lead_vault_hostname}"
}

resource "vault_auth_backend" "kubernetes" {
  provider = vault.lead

  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "k8s_vault_backend_config" {
  provider = vault.lead

  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "https://kubernetes.default.svc"
  kubernetes_ca_cert = data.kubernetes_secret.vault_token_reviewer_service_account_token.data["ca.crt"]
  token_reviewer_jwt = data.kubernetes_secret.vault_token_reviewer_service_account_token.data["token"]
}

resource "vault_mount" "mongodb" {
  provider = vault.lead

  path = "mongodb"
  type = "database"
}
