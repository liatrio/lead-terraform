provider "kubernetes" {
  alias = "staging"
}

provider "helm" {
  alias = "staging"
}

provider "kubernetes" {
  alias = "production"
}

provider "helm" {
  alias = "production"
}

provider "kubernetes" {
  alias = "system"
}

provider "helm" {
  alias = "system"
}

data "kubernetes_secret" "vault_root_token_secret" {
  provider = kubernetes.staging
  metadata {
    namespace = "toolchain"
    name      = "vault-root-token"
  }
}

provider "vault" {
  address = "https://vault.toolchain.${var.cluster_domain}"
  token   = data.kubernetes_secret.vault_root_token_secret.data.token
}

